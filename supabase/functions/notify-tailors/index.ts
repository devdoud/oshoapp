import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { notifyTailorsForOrder } from "../_shared/orders.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    await requireAuthenticatedUser(req);
    const body = await req.json();
    const orderId = typeof body?.order_id === "string"
      ? body.order_id
      : typeof body?.record?.id === "string"
      ? body.record.id
      : null;

    if (!orderId) {
      return jsonResponse({ error: "order_id is required." }, { status: 400 });
    }

    const result = await notifyTailorsForOrder(createServiceClient(), orderId, {
      force: body?.force === true,
    });

    return jsonResponse(result);
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
