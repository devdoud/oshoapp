import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { amount, currency } = await req.json();

    // Validation des paramètres
    if (!amount || !currency) {
      return new Response(
        JSON.stringify({ error: 'Missing amount or currency.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Validation du type de amount
    if (typeof amount !== 'number' || amount <= 0) {
      return new Response(
        JSON.stringify({ error: 'Amount must be a positive number.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    // Validation de currency
    if (typeof currency !== 'string' || currency.length !== 3) {
      return new Response(
        JSON.stringify({ error: 'Currency must be a 3-letter code.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const secretKey = Deno.env.get('STRIPE_SECRET_KEY');
    if (!secretKey) {
      return new Response(
        JSON.stringify({ error: 'Stripe secret key not configured.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const body = new URLSearchParams();
    body.set('amount', Math.round(amount).toString()); // S'assurer que c'est un entier
    body.set('currency', currency.toLowerCase());
    body.set('automatic_payment_methods[enabled]', 'true');

    const stripeRes = await fetch('https://api.stripe.com/v1/payment_intents', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${secretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body,
    });

    const data = await stripeRes.json();

    if (!stripeRes.ok) {
      console.error('Stripe API error:', data);
      return new Response(
        JSON.stringify({ error: data?.error?.message ?? 'Stripe error', details: data }),
        { status: stripeRes.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    return new Response(
      JSON.stringify(data),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('Function error:', err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
