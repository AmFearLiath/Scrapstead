class_name UpgradeStation
extends Interactable
## The workbench (P1): offers the upgrades of the UpgradeCatalog and buys them
## through UpgradeProgress and the Wallet. The panel only displays the offers
## and forwards the purchase request.
##
## Offer dictionary: {"definition", "status", "current", "after"}
##   status: "available", "owned", "insufficient_funds", "locked"

## Emitted after a successful purchase.
signal upgrade_bought(definition: UpgradeDefinition)

var _context: InteractionContext


func get_prompt_detail(context: InteractionContext) -> String:
	if context == null or context.upgrades == null:
		return ""
	for offer: Dictionary in _build_offers(context):
		if offer["status"] == "available":
			return tr("ui.upgrade.detail_available")
	return tr("ui.upgrade.detail_none")


func interact(context: InteractionContext) -> Dictionary:
	_context = context
	var result: Dictionary = make_result(true)
	result["panel"] = "upgrade"
	result["panel_data"] = {"station": self}
	return result


## Current offers for the panel.
func get_offers() -> Array[Dictionary]:
	return _build_offers(_context)


## Buys an upgrade and reports the outcome.
func buy(upgrade_id: String) -> Dictionary:
	if _context == null:
		return make_result(false, "ui.upgrade.failed")
	var definition: UpgradeDefinition = _context.upgrades.get_catalog().get_definition(upgrade_id)
	var outcome: UpgradeProgress.PurchaseResult = _context.upgrades.purchase(upgrade_id, _context.wallet)
	match outcome:
		UpgradeProgress.PurchaseResult.OK:
			upgrade_bought.emit(definition)
			return make_result(true, "ui.upgrade.bought", {"name": tr(definition.name_key)})
		UpgradeProgress.PurchaseResult.INSUFFICIENT_FUNDS:
			return make_result(false, "ui.upgrade.insufficient_funds", {"price": definition.price})
		UpgradeProgress.PurchaseResult.ALREADY_OWNED:
			return make_result(false, "ui.upgrade.already_owned")
		UpgradeProgress.PurchaseResult.MISSING_REQUIREMENT:
			return make_result(false, "ui.upgrade.locked")
	return make_result(false, "ui.upgrade.failed")


func _build_offers(context: InteractionContext) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	if context == null:
		return offers
	for definition: UpgradeDefinition in context.upgrades.get_catalog().upgrades:
		var status: String = "available"
		match context.upgrades.check_purchase(definition.id, context.wallet):
			UpgradeProgress.PurchaseResult.ALREADY_OWNED:
				status = "owned"
			UpgradeProgress.PurchaseResult.INSUFFICIENT_FUNDS:
				status = "insufficient_funds"
			UpgradeProgress.PurchaseResult.MISSING_REQUIREMENT, UpgradeProgress.PurchaseResult.UNKNOWN:
				status = "locked"
		var current: int = _current_stat_value(context, definition.stat)
		var after: int = current if status == "owned" else current + definition.bonus
		offers.append({"definition": definition, "status": status, "current": current, "after": after})
	return offers


func _current_stat_value(context: InteractionContext, stat: String) -> int:
	if stat == UpgradeDefinition.STAT_CARRY_CAPACITY:
		return context.inventory.get_capacity()
	return context.upgrades.get_bonus(stat)
