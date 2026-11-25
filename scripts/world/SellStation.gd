class_name SellStation
extends Interactable
## Fixed sales counter (P1). Prepares a quote of everything the player
## carries and books a confirmed sale exactly once. Prices come from the
## ItemDefinitions (fixed values, no market simulation).
##
## Quote dictionary:
##   id          String  unique transaction ID reserved in the Wallet
##   revision    int     inventory revision the quote was made for
##   lines       Array   [{"item_id", "name_key", "count", "unit_value", "total"}]
##   object_ids  Array   world object IDs included in the sale
##   total       int     credits paid on confirmation

## Emitted after a booked sale with the sold world object IDs.
signal sale_completed(object_ids: Array, total: int)

var _context: InteractionContext


func get_prompt_detail(context: InteractionContext) -> String:
	if context == null or context.inventory == null or context.inventory.is_empty():
		return tr("ui.sell.nothing_short")
	var quote: Dictionary = _calculate(context)
	return tr("ui.sell.detail").format({"count": quote["object_ids"].size(), "total": quote["total"]})


func check_requirements(context: InteractionContext) -> Dictionary:
	if context == null or context.inventory == null or context.inventory.is_empty():
		return {"ok": false, "message_key": "ui.sell.nothing", "message_args": {}}
	return {"ok": true, "message_key": "", "message_args": {}}


func interact(context: InteractionContext) -> Dictionary:
	_context = context
	var result: Dictionary = make_result(true)
	result["panel"] = "sell"
	result["panel_data"] = {"station": self}
	return result


## Creates a fresh quote for the current inventory and reserves its ID.
func create_quote() -> Dictionary:
	var quote: Dictionary = _calculate(_context)
	quote["id"] = _context.wallet.next_transaction_id("sale")
	return quote


## Books a confirmed quote. Fails without any change if the quote is stale
## (inventory changed), was already booked, or does not add up.
func confirm_sale(quote: Dictionary) -> Dictionary:
	if _context == null or quote.is_empty():
		return make_result(false, "ui.sell.failed")
	if _context.wallet.was_booked(quote.get("id", "")):
		return make_result(false, "ui.sell.already_booked")
	if quote.get("revision", -1) != _context.inventory.get_revision():
		return make_result(false, "ui.sell.stale")
	var check: Dictionary = _calculate(_context)
	if check["total"] != quote.get("total", -1) or check["total"] <= 0:
		return make_result(false, "ui.sell.failed")
	if _context.wallet.credit(check["total"], quote["id"], "ui.ledger.sale") != Wallet.Result.OK:
		return make_result(false, "ui.sell.already_booked")
	for object_id: String in check["object_ids"]:
		_context.inventory.remove(object_id)
	sale_completed.emit(check["object_ids"], check["total"])
	return make_result(true, "ui.sell.done", {"count": check["object_ids"].size(), "total": check["total"]})


func _calculate(context: InteractionContext) -> Dictionary:
	var lines: Array = []
	var object_ids: Array = []
	var total: int = 0
	for group: Dictionary in context.inventory.get_grouped():
		var definition: ItemDefinition = group["definition"]
		if definition == null:
			continue
		var line_total: int = definition.sell_value * int(group["count"])
		lines.append({"item_id": definition.id, "name_key": definition.name_key, "count": group["count"],
			"unit_value": definition.sell_value, "total": line_total})
		total += line_total
	for entry: Dictionary in context.inventory.get_entries():
		if context.item_catalog.get_definition(entry["item_id"]) != null:
			object_ids.append(entry["object_id"])
	return {"revision": context.inventory.get_revision(), "lines": lines, "object_ids": object_ids,
		"total": total}
