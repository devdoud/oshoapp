import "jsr:@supabase/functions-js/edge-runtime.d.ts";

import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

const allowedStatuses = new Set([
  "accepted",
  "rejected",
  "in_progress",
  "completed",
  "cancelled",
]);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const user = await requireAuthenticatedUser(req);
    const { assignment_id, order_id, status, notes } = await req.json();

    if (typeof status !== "string" || !allowedStatuses.has(status)) {
      return jsonResponse({ error: "Invalid assignment status." }, { status: 400 });
    }

    const supabase = createServiceClient();
    let query = supabase
      .from("order_assignments")
      .select("id, order_id, tailor_id, status")
      .eq("tailor_id", user.id);

    if (typeof assignment_id === "string" && assignment_id.trim().length > 0) {
      query = query.eq("id", assignment_id);
    } else if (typeof order_id === "string" && order_id.trim().length > 0) {
      query = query.eq("order_id", order_id);
    } else {
      return jsonResponse({ error: "assignment_id or order_id is required." }, { status: 400 });
    }

    const { data: assignment, error: assignmentError } = await query.maybeSingle<{
      id: string;
      order_id: string;
      tailor_id: string;
      status: string;
    }>();

    if (assignmentError) {
      throw new Error(`Unable to load assignment: ${assignmentError.message}`);
    }

    if (!assignment) {
      return jsonResponse({ error: "Assignment not found." }, { status: 404 });
    }

    const now = new Date().toISOString();
    const updates: Record<string, unknown> = {
      status,
      notes: typeof notes === "string" ? notes : null,
    };

    if (status === "accepted") {
      updates.accepted_at = now;
    }
    if (status === "in_progress") {
      updates.started_at = now;
    }
    if (status === "completed") {
      updates.completed_at = now;
    }

    const { data: updatedAssignment, error: updateError } = await supabase
      .from("order_assignments")
      .update(updates)
      .eq("id", assignment.id)
      .select("*")
      .single();

    if (updateError) {
      throw new Error(`Unable to update assignment: ${updateError.message}`);
    }

    if (status === "accepted") {
      const { error: cancelOthersError } = await supabase
        .from("order_assignments")
        .update({ status: "cancelled" })
        .eq("order_id", assignment.order_id)
        .neq("id", assignment.id)
        .eq("status", "pending");

      if (cancelOthersError) {
        throw new Error(`Unable to cancel sibling assignments: ${cancelOthersError.message}`);
      }

      const { error: orderError } = await supabase
        .from("orders")
        .update({
          status: "processing",
          primary_tailor_id: user.id,
        })
        .eq("id", assignment.order_id);

      if (orderError) {
        throw new Error(`Unable to update order after acceptance: ${orderError.message}`);
      }
    }

    if (status === "in_progress") {
      const { error: orderError } = await supabase
        .from("orders")
        .update({ status: "processing" })
        .eq("id", assignment.order_id);

      if (orderError) {
        throw new Error(`Unable to mark order in progress: ${orderError.message}`);
      }
    }

    if (status === "completed") {
      const { error: orderError } = await supabase
        .from("orders")
        .update({ status: "delivered" })
        .eq("id", assignment.order_id);

      if (orderError) {
        throw new Error(`Unable to mark order completed: ${orderError.message}`);
      }
    }

    return jsonResponse({ success: true, assignment: updatedAssignment });
  } catch (error) {
    return jsonResponse(
      { error: error instanceof Error ? error.message : "Unknown error" },
      { status: 500 },
    );
  }
});
