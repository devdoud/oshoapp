import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface CheckoutItemPayload {
  product_id: string;
  quantity: number;
  price: number;
  measurement_profile_id?: string | null;
  customization_details?: Record<string, unknown> | null;
  measurement_snapshot?: Record<string, unknown> | null;
}

export interface CheckoutOrderPayload {
  items: CheckoutItemPayload[];
  shipping_address: Record<string, unknown>;
  shipping_fee?: number;
  payment_method?: string;
  source?: string;
}

interface PaymentAttemptRow {
  id: string;
  user_id: string;
  stripe_payment_intent_id: string;
  amount: number;
  currency: string;
  status: string;
  order_payload: CheckoutOrderPayload;
  order_id: string | null;
  paid_at: string | null;
  notified_at: string | null;
}

interface OrderRow {
  id: string;
  user_id: string;
  status: string;
  total_amount: number;
  payment_status: string;
  shipping_address: Record<string, unknown> | null;
  created_at: string;
  payment_method?: string | null;
  primary_tailor_id?: string | null;
}

function asRecord(value: unknown, fieldName: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${fieldName} must be an object.`);
  }

  return value as Record<string, unknown>;
}

function asNumber(value: unknown, fieldName: string): number {
  if (typeof value !== "number" || Number.isNaN(value) || value < 0) {
    throw new Error(`${fieldName} must be a valid number.`);
  }

  return value;
}

export function validateCheckoutPayload(value: unknown): CheckoutOrderPayload {
  const record = asRecord(value, "order_payload");
  const items = record.items;

  if (!Array.isArray(items) || items.length === 0) {
    throw new Error("order_payload.items must contain at least one item.");
  }

  const normalizedItems = items.map((rawItem, index) => {
    const item = asRecord(rawItem, `order_payload.items[${index}]`);
    const productId = item.product_id;

    if (typeof productId !== "string" || productId.trim().length === 0) {
      throw new Error(`order_payload.items[${index}].product_id is required.`);
    }

    const quantity = Number(item.quantity ?? 1);
    if (!Number.isFinite(quantity) || quantity <= 0) {
      throw new Error(`order_payload.items[${index}].quantity must be > 0.`);
    }

    return {
      product_id: productId,
      quantity,
      price: asNumber(item.price, `order_payload.items[${index}].price`),
      measurement_profile_id:
        typeof item.measurement_profile_id === "string"
          ? item.measurement_profile_id
          : null,
      customization_details: item.customization_details
        ? asRecord(
            item.customization_details,
            `order_payload.items[${index}].customization_details`,
          )
        : null,
      measurement_snapshot: item.measurement_snapshot
        ? asRecord(
            item.measurement_snapshot,
            `order_payload.items[${index}].measurement_snapshot`,
          )
        : null,
    } satisfies CheckoutItemPayload;
  });

  return {
    items: normalizedItems,
    shipping_address: asRecord(record.shipping_address, "shipping_address"),
    shipping_fee:
      record.shipping_fee == null
        ? 0
        : asNumber(record.shipping_fee, "shipping_fee"),
    payment_method:
      typeof record.payment_method === "string" ? record.payment_method : "card",
    source: typeof record.source === "string" ? record.source : "checkout",
  };
}

export function computeOrderTotal(payload: CheckoutOrderPayload) {
  const itemsTotal = payload.items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );

  return Number((itemsTotal + (payload.shipping_fee ?? 0)).toFixed(2));
}

export async function fetchStripePaymentIntent(paymentIntentId: string) {
  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!stripeSecretKey) {
    throw new Error("STRIPE_SECRET_KEY is not configured.");
  }

  const response = await fetch(
    `https://api.stripe.com/v1/payment_intents/${paymentIntentId}`,
    {
      headers: {
        Authorization: `Bearer ${stripeSecretKey}`,
      },
    },
  );

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message ?? "Unable to fetch payment intent.");
  }

  return data as Record<string, unknown>;
}

export async function upsertPaymentAttemptStatus(
  supabase: SupabaseClient,
  paymentIntentId: string,
  status: string,
  extra: Record<string, unknown> = {},
) {
  const updates: Record<string, unknown> = {
    status,
    ...extra,
  };

  if (status === "succeeded" && !updates.paid_at) {
    updates.paid_at = new Date().toISOString();
  }

  const { error } = await supabase
    .from("payment_attempts")
    .update(updates)
    .eq("stripe_payment_intent_id", paymentIntentId);

  if (error) {
    throw new Error(`Unable to update payment attempt: ${error.message}`);
  }
}

async function fetchMeasurementSnapshots(
  supabase: SupabaseClient,
  payload: CheckoutOrderPayload,
) {
  const cache = new Map<string, Record<string, unknown>>();

  for (const item of payload.items) {
    if (!item.measurement_profile_id || item.measurement_snapshot) {
      continue;
    }

    if (!cache.has(item.measurement_profile_id)) {
      const { data, error } = await supabase
        .from("measurement_profiles")
        .select("*")
        .eq("id", item.measurement_profile_id)
        .maybeSingle();

      if (error) {
        throw new Error(
          `Unable to load measurement profile ${item.measurement_profile_id}: ${error.message}`,
        );
      }

      if (data) {
        cache.set(item.measurement_profile_id, data as Record<string, unknown>);
      }
    }
  }

  return cache;
}

async function fetchOrderWithItems(supabase: SupabaseClient, orderId: string) {
  const { data, error } = await supabase
    .from("orders")
    .select("*, order_items(*)")
    .eq("id", orderId)
    .single();

  if (error || !data) {
    throw new Error(`Unable to load created order ${orderId}.`);
  }

  return data;
}

export async function notifyTailorsForOrder(
  supabase: SupabaseClient,
  orderId: string,
  _options: { force?: boolean } = {},
) {
  const { data: order, error: orderError } = await supabase
    .from("orders")
    .select("id")
    .eq("id", orderId)
    .single<{ id: string }>();

  if (orderError || !order) {
    throw new Error(`Unable to find order ${orderId}.`);
  }

  return {
    success: true,
    order_id: orderId,
    message: "Assignment is handled manually by admin via Supabase.",
    notifications_sent: 0,
    results: [],
  };
}

export async function createOrderFromPaymentAttempt(
  supabase: SupabaseClient,
  paymentIntentId: string,
) {
  const { data, error } = await supabase
    .from("payment_attempts")
    .select("*")
    .eq("stripe_payment_intent_id", paymentIntentId)
    .maybeSingle<PaymentAttemptRow>();

  if (error) {
    throw new Error(`Unable to load payment attempt: ${error.message}`);
  }

  if (!data) {
    throw new Error(`No payment attempt found for ${paymentIntentId}.`);
  }

  if (data.order_id) {
    const order = await fetchOrderWithItems(supabase, data.order_id);
    return {
      order,
      created: false,
      notify_result: {
        success: true,
        order_id: data.order_id,
        notifications_sent: 0,
        results: [],
      },
    };
  }

  const payload = validateCheckoutPayload(data.order_payload);
  const expectedTotal = computeOrderTotal(payload);
  if (Math.abs(expectedTotal - Number(data.amount)) > 0.01) {
    throw new Error(
      `Order total mismatch for payment attempt ${data.id}: expected ${expectedTotal}, got ${data.amount}.`,
    );
  }

  const measurementSnapshots = await fetchMeasurementSnapshots(supabase, payload);

  const { data: order, error: orderError } = await supabase
    .from("orders")
    .insert({
      user_id: data.user_id,
      status: "pending",
      total_amount: data.amount,
      payment_status: "completed",
      payment_method: payload.payment_method ?? "card",
      shipping_address: payload.shipping_address,
      paid_at: data.paid_at ?? new Date().toISOString(),
      stripe_payment_intent_id: data.stripe_payment_intent_id,
    })
    .select("id")
    .single<{ id: string }>();

  if (orderError || !order) {
    throw new Error(`Unable to create order: ${orderError?.message ?? "unknown error"}`);
  }

  const orderItems = payload.items.map((item) => ({
    order_id: order.id,
    product_id: item.product_id,
    quantity: item.quantity,
    price: item.price,
    unit_price: item.price,
    total_price: item.price * item.quantity,
    measurement_profile_id: item.measurement_profile_id,
    customization_details: item.customization_details,
    measurement_snapshot:
      item.measurement_snapshot ??
      (item.measurement_profile_id
        ? measurementSnapshots.get(item.measurement_profile_id) ?? null
        : null),
  }));

  const { error: itemsError } = await supabase
    .from("order_items")
    .insert(orderItems);

  if (itemsError) {
    throw new Error(`Unable to create order items: ${itemsError.message}`);
  }

  const { error: attemptError } = await supabase
    .from("payment_attempts")
    .update({
      status: "succeeded",
      order_id: order.id,
      order_created_at: new Date().toISOString(),
      paid_at: data.paid_at ?? new Date().toISOString(),
      error_message: null,
    })
    .eq("id", data.id);

  if (attemptError) {
    throw new Error(`Unable to update payment attempt: ${attemptError.message}`);
  }

  const completedOrder = await fetchOrderWithItems(supabase, order.id);

  return {
    order: completedOrder,
    created: true,
    notify_result: {
      success: true,
      order_id: order.id,
      message: "Assignment is handled manually by admin via Supabase.",
      notifications_sent: 0,
      results: [],
    },
  };
}

