import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const user = await requireAuthenticatedUser(req);
    const supabase = createServiceClient();
    const url = new URL(req.url);
    const statuses = url.searchParams.get("statuses")
      ?.split(",")
      .map((value) => value.trim())
      .filter(Boolean) ?? [];

    let query = supabase
      .from("order_assignments")
      .select(
        "id, order_id, tailor_id, status, assigned_at, accepted_at, started_at, completed_at, notes, order:orders!inner(*, order_items(*, product:products(*)))",
      )
      .eq("tailor_id", user.id)
      .order("assigned_at", { ascending: false });

    if (statuses.length > 0) {
      query = query.in("status", statuses);
    }

    const { data, error } = await query;
    if (error) {
      throw new Error(`Unable to load tailor orders: ${error.message}`);
    }

    return jsonResponse({ assignments: data ?? [] });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
