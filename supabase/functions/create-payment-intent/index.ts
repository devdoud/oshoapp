import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { computeOrderTotal, validateCheckoutPayload } from "../_shared/orders.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

const zeroDecimalCurrencies = new Set(["bif", "clp", "djf", "gnf", "jpy", "kmf", "krw", "mga", "pyg", "rwf", "ugx", "vnd", "vuv", "xaf", "xof", "xpf"]);

function toStripeAmount(totalAmount: number, currency: string) {
  return zeroDecimalCurrencies.has(currency.toLowerCase())
    ? Math.round(totalAmount)
    : Math.round(totalAmount * 100);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const user = await requireAuthenticatedUser(req);
    const { amount, currency, order_payload } = await req.json();

    if (typeof amount !== "number" || amount <= 0) {
      return jsonResponse({ error: "amount must be a positive number." }, { status: 400 });
    }

    if (typeof currency !== "string" || currency.trim().length !== 3) {
      return jsonResponse({ error: "currency must be a 3-letter code." }, { status: 400 });
    }

    const normalizedCurrency = currency.toLowerCase();
    const payload = validateCheckoutPayload(order_payload);
    const orderTotal = computeOrderTotal(payload);
    const expectedAmount = toStripeAmount(orderTotal, normalizedCurrency);

    if (expectedAmount != Math.round(amount)) {
      return jsonResponse(
        {
          error: "Payment amount does not match order payload total.",
          expected_amount: expectedAmount,
          received_amount: amount,
        },
        { status: 400 },
      );
    }

    const secretKey = Deno.env.get("STRIPE_SECRET_KEY");
    if (!secretKey) {
      throw new Error("STRIPE_SECRET_KEY is not configured.");
    }

    const attemptId = crypto.randomUUID();
    const body = new URLSearchParams();
    body.set("amount", String(expectedAmount));
    body.set("currency", normalizedCurrency);
    body.set("automatic_payment_methods[enabled]", "true");
    body.set("metadata[attempt_id]", attemptId);
    body.set("metadata[user_id]", user.id);
    body.set("metadata[source]", payload.source ?? "checkout");

    const stripeResponse = await fetch("https://api.stripe.com/v1/payment_intents", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${secretKey}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body,
    });

    const stripeData = await stripeResponse.json();
    if (!stripeResponse.ok) {
      return jsonResponse(
        {
          error: stripeData?.error?.message ?? "Unable to create payment intent.",
          details: stripeData,
        },
        { status: stripeResponse.status },
      );
    }

    const supabase = createServiceClient();
    const { error: insertError } = await supabase.from("payment_attempts").insert({
      id: attemptId,
      user_id: user.id,
      stripe_payment_intent_id: stripeData.id,
      amount: orderTotal,
      currency: normalizedCurrency,
      status: stripeData.status ?? "requires_payment_method",
      order_payload: payload,
    });

    if (insertError) {
      return jsonResponse(
        { error: `Unable to persist payment attempt: ${insertError.message}` },
        { status: 500 },
      );
    }

    return jsonResponse({
      id: stripeData.id,
      client_secret: stripeData.client_secret,
      payment_attempt_id: attemptId,
      status: stripeData.status,
    });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
