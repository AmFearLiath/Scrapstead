class_name OrderDesk
extends Interactable
## Office desk with Walt's old mail-order catalog (P1 deepening). Offers the
## wares of the UpgradeCatalog (tools, carry upgrades) and buys them through
## UpgradeProgress and the Wallet. Bought wares are "delivered" instantly: the
## matching child of `delivery_area` becomes visible. The catalog panel only
## displays the offers and forwards purchase requests.
##
## Offer dictionary: {"definition", "status", "current", "after"}
##   status: "available", "owned", "insufficient_funds", "locked"

## Emitted after a successful purchase.
signal ware_bought(definition: UpgradeDefinition)

## Node whose children are named after ware IDs and show delivered goods.
@export var delivery_area: Node3D

var _context: InteractionContext


func get_prompt_detail(context: InteractionContext) -> String:
	if context == null or context.upgrades == null:
		return ""
	for offer: Dictionary in _build_offers(context):
		if offer["status"] == "available":
			return tr("ui.catalog.detail_available")
	return tr("ui.catalog.detail_none")


func interact(context: InteractionContext) -> Dictionary:
	_context = context
	var result: Dictionary = make_result(true)
	result["panel"] = "catalog"
	result["panel_data"] = {"station": self}
	return result


## Current offers for the panel.
func get_offers() -> Array[Dictionary]:
	return _build_offers(_context)


## Buys a ware and reports the outcome.
func buy(upgrade_id: String) -> Dictionary:
	if _context == null:
		return make_result(false, "ui.catalog.failed")
	var definition: UpgradeDefinition = _context.upgrades.get_catalog().get_definition(upgrade_id)
	var outcome: UpgradeProgress.PurchaseResult = _context.upgrades.purchase(upgrade_id, _context.wallet)
	match outcome:
		UpgradeProgress.PurchaseResult.OK:
			refresh_deliveries(_context.upgrades)
			ware_bought.emit(definition)
			return make_result(true, "upgrade.%s.bought" % definition.id)
		UpgradeProgress.PurchaseResult.INSUFFICIENT_FUNDS:
			return make_result(false, "ui.catalog.insufficient_funds", {"price": definition.price})
		UpgradeProgress.PurchaseResult.ALREADY_OWNED:
			return make_result(false, "ui.catalog.already_owned")
		UpgradeProgress.PurchaseResult.MISSING_REQUIREMENT:
			return make_result(false, "ui.catalog.locked",
				{"requirement": tr(_context.upgrades.get_catalog().get_definition(definition.requires).name_key)})
	return make_result(false, "ui.catalog.failed")


## Shows delivered goods for every owned ware.
func refresh_deliveries(upgrades: UpgradeProgress) -> void:
	if delivery_area == null:
		return
	for child: Node in delivery_area.get_children():
		if child is Node3D:
			(child as Node3D).visible = upgrades.is_owned(child.name)


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
		var current: int = context.inventory.get_capacity()
		var after: int = current if status == "owned" else current + definition.bonus
		offers.append({"definition": definition, "status": status, "current": current, "after": after})
	return offers
