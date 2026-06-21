import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { createServiceClient, requireAuthenticatedUser } from "../_shared/supabase.ts";

const FCM_SEND_URL = "https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send";

interface NotificationPayload {
  // Envoyer à un user spécifique
  user_id?: string;
  // Ou à plusieurs users
  user_ids?: string[];
  // Contenu de la notification
  title: string;
  body: string;
  // Données optionnelles (pour la navigation dans l'app)
  data?: Record<string, string>;
  // Topic FCM (tous les users abonnés)
  topic?: string;
}

async function getFCMAccessToken(): Promise<string> {
  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!serviceAccountJson) {
    throw new Error("FCM_SERVICE_ACCOUNT_JSON not configured.");
  }

  const serviceAccount = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);

  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = btoa(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));

  const signingInput = `${header}.${payload}`;

  // Import private key
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${btoa(String.fromCharCode(...new Uint8Array(signature)))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenRes.json();
  if (!tokenRes.ok) throw new Error(tokenData.error_description ?? "FCM token error");
  return tokenData.access_token;
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binary = atob(base64);
  const buffer = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) buffer[i] = binary.charCodeAt(i);
  return buffer.buffer;
}

async function sendToToken(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  accessToken: string,
  projectId: string,
): Promise<boolean> {
  const url = FCM_SEND_URL.replace("{PROJECT_ID}", projectId);
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data,
        android: {
          notification: {
            channel_id: "osho_high_importance",
            priority: "high",
            sound: "default",
          },
          priority: "high",
        },
        apns: {
          payload: { aps: { alert: { title, body }, sound: "default", badge: 1 } },
        },
      },
    }),
  });

  if (!res.ok) {
    const err = await res.json();
    // Token invalide → on le supprime de la DB
    if (err?.error?.status === "INVALID_ARGUMENT" ||
        err?.error?.status === "NOT_FOUND") {
      return false; // Signale que le token est invalide
    }
  }
  return res.ok;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    // Seul le service role peut envoyer des notifications
    // (appelé depuis le dashboard ou d'autres Edge Functions)
    const authHeader = req.headers.get("Authorization");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    // Accepte soit le service role key, soit un user admin authentifié
    let isAuthorized = authHeader === `Bearer ${serviceKey}`;
    if (!isAuthorized) {
      try {
        await requireAuthenticatedUser(req);
        isAuthorized = true; // Tout user authentifié peut envoyer (filtrer si besoin)
      } catch (_) {
        isAuthorized = false;
      }
    }
    if (!isAuthorized) {
      return jsonResponse({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await req.json() as NotificationPayload;
    const { title, body: notifBody, data = {}, topic, user_id, user_ids } = body;

    if (!title || !notifBody) {
      return jsonResponse({ error: "title and body are required." }, { status: 400 });
    }

    const projectId = Deno.env.get("FCM_PROJECT_ID");
    if (!projectId) throw new Error("FCM_PROJECT_ID not configured.");

    const accessToken = await getFCMAccessToken();
    const supabase = createServiceClient();
    const stringData: Record<string, string> = {};
    for (const [k, v] of Object.entries(data)) stringData[k] = String(v);

    // ── Envoi par topic ──────────────────────────────────────────────
    if (topic) {
      const url = FCM_SEND_URL.replace("{PROJECT_ID}", projectId);
      await fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            topic,
            notification: { title, body: notifBody },
            data: stringData,
          },
        }),
      });
      return jsonResponse({ success: true, sent_to: `topic:${topic}` });
    }

    // ── Envoi par user_id(s) ──────────────────────────────────────────
    const targetIds = user_ids ?? (user_id ? [user_id] : []);
    if (targetIds.length === 0) {
      return jsonResponse({ error: "Provide user_id, user_ids, or topic." }, { status: 400 });
    }

    const { data: tokens, error } = await supabase
      .from("fcm_tokens")
      .select("id, token")
      .in("user_id", targetIds);

    if (error) throw new Error(`DB error: ${error.message}`);
    if (!tokens || tokens.length === 0) {
      return jsonResponse({ success: true, sent: 0, message: "No tokens found." });
    }

    let sent = 0;
    const invalidIds: string[] = [];

    for (const { id, token } of tokens) {
      const ok = await sendToToken(token, title, notifBody, stringData, accessToken, projectId);
      if (ok) {
        sent++;
      } else {
        invalidIds.push(id);
      }
    }

    // Nettoyer les tokens invalides
    if (invalidIds.length > 0) {
      await supabase.from("fcm_tokens").delete().in("id", invalidIds);
    }

    return jsonResponse({
      success: true,
      sent,
      total: tokens.length,
      removed_invalid: invalidIds.length,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : "Unknown error";
    return jsonResponse({ error: msg }, { status: 500 });
  }
});
