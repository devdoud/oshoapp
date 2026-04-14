import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  createOrderFromPaymentAttempt,
  fetchStripePaymentIntent,
  upsertPaymentAttemptStatus,
} from "../_shared/orders.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const user = await requireAuthenticatedUser(req);
    const { payment_intent_id } = await req.json();

    if (typeof payment_intent_id !== "string" || payment_intent_id.trim().length === 0) {
      return jsonResponse({ error: "payment_intent_id is required." }, { status: 400 });
    }

    const supabase = createServiceClient();
    const { data: attempt, error: attemptError } = await supabase
      .from("payment_attempts")
      .select("id, user_id, status, order_id")
      .eq("stripe_payment_intent_id", payment_intent_id)
      .maybeSingle<{ id: string; user_id: string; status: string; order_id: string | null }>();

    if (attemptError) {
      throw new Error(`Unable to load payment attempt: ${attemptError.message}`);
    }

    if (!attempt || attempt.user_id !== user.id) {
      return jsonResponse({ error: "Payment attempt not found." }, { status: 404 });
    }

    const paymentIntent = await fetchStripePaymentIntent(payment_intent_id);
    const paymentStatus = String(paymentIntent.status ?? "unknown");

    if (paymentStatus !== "succeeded") {
      await upsertPaymentAttemptStatus(supabase, payment_intent_id, paymentStatus);
      return jsonResponse(
        {
          error: "Payment is not confirmed yet.",
          payment_status: paymentStatus,
        },
        { status: 409 },
      );
    }

    const paidAt = typeof paymentIntent.created === "number"
      ? new Date(paymentIntent.created * 1000).toISOString()
      : new Date().toISOString();

    await upsertPaymentAttemptStatus(supabase, payment_intent_id, "succeeded", {
      paid_at: paidAt,
      error_message: null,
    });

    const result = await createOrderFromPaymentAttempt(supabase, payment_intent_id);

    return jsonResponse({
      success: true,
      created: result.created,
      order: result.order,
      notify_result: result.notify_result,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
