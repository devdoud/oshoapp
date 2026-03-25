import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { JWT } from "https://esm.sh/google-auth-library@9"

serve(async (req) => {
  try {
    // 1. Récupérer les données de la nouvelle commande via le Webhook Supabase
    const { record } = await req.json()

    // Safety Check: Only notify if payment_status is 'completed'
    if (record.payment_status !== 'completed') {
      console.log(`[NOTIFY-TAILORS] Notification skipped: payment_status is '${record.payment_status}', not 'completed'`)
      return new Response(JSON.stringify({ message: "Paiement non confirmé, notification non envoyée" }), { status: 200 })
    }

    // 2. Initialiser Supabase avec les clés du serveur
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 3. Récupérer les tokens de tous les tailleurs
    const { data: tokens, error: tokenError } = await supabase
      .from('tailor_tokens')
      .select('fcm_token')

    if (tokenError || !tokens || tokens.length === 0) {
      return new Response(JSON.stringify({ message: "Aucun tailleur à notifier" }), { status: 200 })
    }

    // 4. Authentification Google (C'est ici qu'on utilise ton fichier JSON)
    // On récupère les valeurs depuis les Secrets Supabase que tu vas configurer
    const client = new JWT({
      email: Deno.env.get('FCM_CLIENT_EMAIL'),
      key: Deno.env.get('FCM_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
    })

    const jwtToken = await client.getAccessToken()

    // 5. Envoyer la notification à chaque token
    const projectId = Deno.env.get('FCM_PROJECT_ID')
    const results = []

    for (const item of tokens) {
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${jwtToken.token}`,
        },
        body: JSON.stringify({
          message: {
            token: item.fcm_token,
            notification: {
              title: "Nouvelle commande Osho ! 🧵",
              body: `Un client a commandé : ${record.product_name ?? 'Nouveau modèle'}`
            },
            data: {
              order_id: record.id.toString(),
              click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
          }
        })
      })
      results.push(await res.json())
    }

    return new Response(JSON.stringify({ success: true, results }), { headers: { "Content-Type": "application/json" } })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 })
  }
})