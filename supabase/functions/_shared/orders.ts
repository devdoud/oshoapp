import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

// ── Server-side tax computation ───────────────────────────────────────────────
// Mirror of lib/utils/helpers/tax_service.dart — MUST stay in sync.
// This is the authoritative source: client values are NEVER trusted for taxes.

interface TaxInfo { rate: number; label: string; amount: number }

// Strips diacritics: "Bénin" → "Benin"
function removeDiacritics(s: string): string {
  return s.normalize("NFD").replace(/[̀-ͯ]/g, "");
}

// ── Taux par état US (Tax Foundation 2024) ────────────────────────────────────
const US_STATE_TAX: Record<string, number> = {
  AL:0.0924, AK:0.0176, AZ:0.0837, AR:0.0946, CA:0.0882, CO:0.0777,
  CT:0.0635, DE:0.0000, DC:0.0600, FL:0.0702, GA:0.0733, HI:0.0444,
  ID:0.0602, IL:0.0886, IN:0.0700, IA:0.0694, KS:0.0868, KY:0.0600,
  LA:0.0955, ME:0.0550, MD:0.0600, MA:0.0625, MI:0.0600, MN:0.0749,
  MS:0.0707, MO:0.0829, MT:0.0000, NE:0.0694, NV:0.0823, NH:0.0000,
  NJ:0.0660, NM:0.0783, NY:0.0852, NC:0.0698, ND:0.0696, OH:0.0724,
  OK:0.0898, OR:0.0000, PA:0.0634, RI:0.0700, SC:0.0744, SD:0.0640,
  TN:0.0955, TX:0.0819, UT:0.0718, VT:0.0624, VA:0.0575, WA:0.0938,
  WV:0.0655, WI:0.0543, WY:0.0533,
};

// ── Taux par province Canada (Agence du revenu du Canada 2024) ────────────────
const CA_PROVINCE_TAX: Record<string, { rate: number; label: string }> = {
  AB: { rate:0.05,     label:"GST"     },
  BC: { rate:0.12,     label:"GST+PST" },
  MB: { rate:0.12,     label:"GST+PST" },
  NB: { rate:0.15,     label:"TVH"     },
  NL: { rate:0.15,     label:"TVH"     },
  NS: { rate:0.15,     label:"TVH"     },
  NT: { rate:0.05,     label:"TPS"     },
  NU: { rate:0.05,     label:"TPS"     },
  ON: { rate:0.13,     label:"TVH"     },
  PE: { rate:0.15,     label:"TVH"     },
  QC: { rate:0.14975,  label:"TPS+TVQ" },
  SK: { rate:0.11,     label:"TPS+TVP" },
  YT: { rate:0.05,     label:"TPS"     },
};

// ISO 3166-1 alpha-2 → tax rule index (built lazily from TAX_RULES)
const ISO2_TAX_MAP: Record<string, number> = {
  BJ: 0,  CI: 1,  SN: 2,  TG: 3,  BF: 4,  ML: 5,  NE: 6,  GW: 7,  // UEMOA
  CM: 8,  GA: 9,  CG: 10, TD: 11,                                    // CEMAC
  NG: 12, GH: 13, KE: 14, ZA: 15, MA: 16, TN: 17, EG: 18,            // Africa
  FR: 19, GB: 20, DE: 21, IT: 22, ES: 23, BE: 24, NL: 25, PT: 26,    // Europe
  CH: 27, SE: 28,
  CA: 29, US: 30, BR: 31, MX: 32,                                    // Americas
  AU: 33, NZ: 34, JP: 35, IN: 36, SG: 37,                            // Asia/Oceania
};

const TAX_RULES: Array<{ patterns: string[]; rate: number; label: string }> = [
  // UEMOA
  { patterns: ["benin", "bénin"],                   rate: 0.18,   label: "TVA" },
  { patterns: ["cote d'ivoire", "côte d'ivoire", "ivory coast", "cote", "côte"],
                                                     rate: 0.18,   label: "TVA" },
  { patterns: ["senegal", "sénégal"],               rate: 0.18,   label: "TVA" },
  { patterns: ["togo"],                              rate: 0.18,   label: "TVA" },
  { patterns: ["burkina"],                           rate: 0.18,   label: "TVA" },
  { patterns: ["mali"],                              rate: 0.18,   label: "TVA" },
  { patterns: ["niger"],                             rate: 0.19,   label: "TVA" },
  { patterns: ["guinee-bissau", "guinea-bissau"],    rate: 0.15,   label: "TVA" },
  // CEMAC
  { patterns: ["cameroun", "cameroon"],              rate: 0.1925, label: "TVA" },
  { patterns: ["gabon"],                             rate: 0.18,   label: "TVA" },
  { patterns: ["congo"],                             rate: 0.18,   label: "TVA" },
  { patterns: ["tchad", "chad"],                    rate: 0.18,   label: "TVA" },
  // Other Africa
  { patterns: ["nigeria", "nigéria"],               rate: 0.075,  label: "VAT" },
  { patterns: ["ghana"],                             rate: 0.15,   label: "VAT" },
  { patterns: ["kenya"],                             rate: 0.16,   label: "VAT" },
  { patterns: ["south africa", "afrique du sud"],   rate: 0.15,   label: "VAT" },
  { patterns: ["maroc", "morocco"],                 rate: 0.20,   label: "TVA" },
  { patterns: ["tunisie", "tunisia"],               rate: 0.19,   label: "TVA" },
  { patterns: ["egypte", "egypt"],                  rate: 0.14,   label: "VAT" },
  // Europe
  { patterns: ["france"],                            rate: 0.20,   label: "TVA" },
  { patterns: ["united kingdom", "royaume-uni", "uk", "great britain"],
                                                     rate: 0.20,   label: "VAT" },
  { patterns: ["germany", "allemagne"],              rate: 0.19,   label: "VAT" },
  { patterns: ["italy", "italie"],                  rate: 0.22,   label: "IVA" },
  { patterns: ["spain", "espagne"],                 rate: 0.21,   label: "IVA" },
  { patterns: ["belgium", "belgique"],              rate: 0.21,   label: "TVA" },
  { patterns: ["netherlands", "pays-bas"],          rate: 0.21,   label: "BTW" },
  { patterns: ["portugal"],                          rate: 0.23,   label: "IVA" },
  { patterns: ["switzerland", "suisse"],            rate: 0.077,  label: "TVA" },
  { patterns: ["sweden", "suede", "suède"],         rate: 0.25,   label: "Moms"},
  // Americas
  { patterns: ["canada"],                            rate: 0.05,   label: "TPS" },
  // USA: sales tax moyenne nationale ~8 % (varie par état, 4-11 %)
  { patterns: ["united states", "etats-unis", "états-unis", "usa"],
                                                     rate: 0.08,   label: "Sales Tax" },
  // Asia / Oceania
  { patterns: ["australia", "australie"],           rate: 0.10,   label: "GST" },
  { patterns: ["new zealand", "nouvelle-zelande"],  rate: 0.15,   label: "GST" },
  { patterns: ["japan", "japon"],                   rate: 0.10,   label: "CT"  },
  { patterns: ["india", "inde"],                    rate: 0.18,   label: "GST" },
  { patterns: ["singapore", "singapour"],           rate: 0.09,   label: "GST" },
];

export function computeTaxInfo(
  country: string | undefined | null,
  baseAmount: number,
  countryIso2?: string | null,
  region?: string | null,
): TaxInfo {
  const iso2 = countryIso2?.trim().toUpperCase() ?? "";

  // ── Priorité 1 : état US précis ──────────────────────────────────────────
  if ((iso2 === "US" || (!iso2 && country?.toLowerCase().includes("states"))) && region) {
    const stateCode = region.trim().toUpperCase();
    const rate = US_STATE_TAX[stateCode];
    if (rate !== undefined) {
      const amount = Number((baseAmount * rate).toFixed(2));
      return { rate, label: "Sales Tax", amount };
    }
  }

  // ── Priorité 2 : province Canada précise ─────────────────────────────────
  if ((iso2 === "CA" || (!iso2 && country?.toLowerCase().includes("canada"))) && region) {
    const provCode = region.trim().toUpperCase();
    const prov = CA_PROVINCE_TAX[provCode];
    if (prov) {
      const amount = Number((baseAmount * prov.rate).toFixed(2));
      return { rate: prov.rate, label: prov.label, amount };
    }
  }

  // ── Priorité 3 : code ISO pays (taux national) ───────────────────────────
  if (iso2) {
    const idx = ISO2_TAX_MAP[iso2];
    if (idx !== undefined) {
      const rule = TAX_RULES[idx];
      const amount = Number((baseAmount * rule.rate).toFixed(2));
      return { rate: rule.rate, label: rule.label, amount };
    }
  }

  // ── Priorité 4 : nom du pays normalisé ───────────────────────────────────
  if (!country?.trim()) return { rate: 0, label: "", amount: 0 };
  const n = removeDiacritics(country.trim().toLowerCase());
  for (const rule of TAX_RULES) {
    for (const p of rule.patterns) {
      const np = removeDiacritics(p);
      if (n.includes(np) || np.includes(n)) {
        const amount = Number((baseAmount * rule.rate).toFixed(2));
        return { rate: rule.rate, label: rule.label, amount };
      }
    }
  }
  return { rate: 0, label: "", amount: 0 };
}

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
  customer_note?: string | null;
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
    customer_note:
      typeof record.customer_note === "string" && record.customer_note.trim().length > 0
        ? record.customer_note.trim().slice(0, 500)
        : null,
  };
}

export function computeOrderTotal(payload: CheckoutOrderPayload) {
  const itemsTotal = payload.items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0,
  );
  const shippingFee = payload.shipping_fee ?? 0;

  // Tax is computed SERVER-SIDE — ISO code takes priority over name matching.
  const country = (payload.shipping_address?.country as string) ?? "";
  const iso2 = (payload.shipping_address?.country_iso2 as string) ?? null;
  const region = (payload.shipping_address?.region as string) ?? null;
  const tax = computeTaxInfo(country, itemsTotal, iso2, region);

  return Number((itemsTotal + shippingFee + tax.amount).toFixed(2));
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

  // Recompute tax server-side for storage (never trust client-sent tax values)
  const itemsTotal = payload.items.reduce(
    (sum, item) => sum + item.price * item.quantity, 0,
  );
  const country = (payload.shipping_address?.country as string) ?? "";
  const iso2 = (payload.shipping_address?.country_iso2 as string) ?? null;
  const region = (payload.shipping_address?.region as string) ?? null;
  const tax = computeTaxInfo(country, itemsTotal, iso2, region);

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
      tax_amount: tax.amount,
      tax_rate: tax.rate,
      tax_label: tax.label,
      customer_note: payload.customer_note ?? null,
    })
    .select("id")
    .single<{ id: string }>();

  if (orderError) {
    // PostgreSQL unique_violation (23505): a concurrent process already created
    // the order for this payment intent — return the existing one instead.
    if ((orderError as { code?: string }).code === "23505") {
      const { data: existing } = await supabase
        .from("orders")
        .select("id")
        .eq("stripe_payment_intent_id", data.stripe_payment_intent_id)
        .maybeSingle<{ id: string }>();
      if (existing) {
        const completedOrder = await fetchOrderWithItems(supabase, existing.id);
        return {
          order: completedOrder,
          created: false,
          notify_result: { success: true, order_id: existing.id, notifications_sent: 0, results: [] },
        };
      }
    }
    throw new Error(`Unable to create order: ${orderError.message}`);
  }

  if (!order) {
    throw new Error("Unable to create order: unknown error");
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

