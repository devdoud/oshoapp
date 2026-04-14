# Tailor App Integration Contract

## Notification payload
When a paid order is created, the backend sends an FCM message with:

- `data.type = new_order`
- `data.order_id = <uuid>`
- `data.total_amount = <string>`
- `data.item_count = <string>`
- `data.status = pending`
- Android channel id: `tailor_orders`
- Android sound: `new_order`
- iOS sound: `new_order.caf`

## Required tailor app work

1. Register the device token into `public.tailor_tokens` with the authenticated tailor id.
2. Create a high-priority notification channel named `tailor_orders`.
3. Play `new_order` / `new_order.caf` on foreground and background notifications.
4. On notification tap, open the order detail for `order_id`.

## Backend endpoints

### `get-tailor-orders`
Authenticated endpoint.
Returns assignments for the connected tailor with embedded order and order items.
Optional query param: `statuses=pending,accepted`

### `update-assignment-status`
Authenticated endpoint.
Accepted statuses:
- `accepted`
- `rejected`
- `in_progress`
- `completed`
- `cancelled`

Body:
```json
{
  "assignment_id": "<uuid>",
  "status": "accepted",
  "notes": "optional"
}
```

Effects:
- `accepted`: marks the order `processing`, assigns `primary_tailor_id`, cancels sibling pending assignments.
- `in_progress`: keeps the order `processing`.
- `completed`: marks the order `delivered`.
