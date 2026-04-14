import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { jsonResponse } from "../_shared/cors.ts";
import {
  createOrderFromPaymentAttempt,
  upsertPaymentAttemptStatus,
} from "../_shared/orders.ts";
import { createServiceClient } from "../_shared/supabase.ts";

function secureCompare(a: string, b: string) {
  if (a.length !== b.length) {
    return false;
  }

  let result = 0;
  for (let index = 0; index < a.length; index++) {
    result |= a.charCodeAt(index) ^ b.charCodeAt(index);
  }

  return result === 0;
}

async function verifyStripeSignature(payload: string, signatureHeader: string, secret: string) {
  const parts = signatureHeader.split(",").map((part) => part.trim());
  const timestampPart = parts.find((part) => part.startsWith("t="));
  const signatureParts = parts
    .filter((part) => part.startsWith("v1="))
    .map((part) => part.slice(3));

  if (!timestampPart || signatureParts.length === 0) {
    return false;
  }

  const timestamp = Number(timestampPart.slice(2));
  if (!Number.isFinite(timestamp)) {
    return false;
  }

  const ageInSeconds = Math.abs(Math.floor(Date.now() / 1000) - timestamp);
  if (ageInSeconds > 300) {
    return false;
  }

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signedPayload = `${timestamp}.${payload}`;
  const signature = await crypto.subtle.sign("HMAC", key, encoder.encode(signedPayload));
  const computed = Array.from(new Uint8Array(signature))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");

  return signatureParts.some((candidate) => secureCompare(candidate, computed));
}

Deno.serve(async (req: Request) => {
  try {
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
    if (!webhookSecret) {
      throw new Error("STRIPE_WEBHOOK_SECRET is not configured.");
    }

    const signature = req.headers.get("stripe-signature");
    if (!signature) {
      return jsonResponse({ error: "Missing Stripe signature." }, { status: 400 });
    }

    const payload = await req.text();
    const isValid = await verifyStripeSignature(payload, signature, webhookSecret);
    if (!isValid) {
      return jsonResponse({ error: "Invalid Stripe signature." }, { status: 400 });
    }

    const event = JSON.parse(payload) as {
      type?: string;
      data?: { object?: Record<string, unknown> };
    };

    const object = event.data?.object ?? {};
    const paymentIntentId = typeof object.id === "string" ? object.id : null;
    if (!paymentIntentId) {
      return jsonResponse({ received: true, skipped: true });
    }

    const supabase = createServiceClient();

    if (event.type === "payment_intent.succeeded") {
      const paidAt = typeof object.created === "number"
        ? new Date(object.created * 1000).toISOString()
        : new Date().toISOString();

      await upsertPaymentAttemptStatus(supabase, paymentIntentId, "succeeded", {
        paid_at: paidAt,
        error_message: null,
      });

      const result = await createOrderFromPaymentAttempt(supabase, paymentIntentId);
      return jsonResponse({ received: true, created: result.created, order_id: result.order.id });
    }

    if (event.type === "payment_intent.payment_failed") {
      const errorMessage = typeof object.last_payment_error === "object" && object.last_payment_error
        ? String((object.last_payment_error as Record<string, unknown>).message ?? "Payment failed")
        : "Payment failed";

      await upsertPaymentAttemptStatus(supabase, paymentIntentId, "failed", {
        error_message: errorMessage,
      });
      return jsonResponse({ received: true, status: "failed" });
    }

    if (event.type === "payment_intent.canceled") {
      await upsertPaymentAttemptStatus(supabase, paymentIntentId, "cancelled");
      return jsonResponse({ received: true, status: "cancelled" });
    }

    return jsonResponse({ received: true, ignored: true });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
