class_name UpgradeProgress
extends RefCounted
## Purchased upgrades and their effect on stats. Purchases are paid through the
## Wallet; the transaction ID per upgrade guarantees a single booking.

signal upgrade_purchased(definition: UpgradeDefinition)

enum PurchaseResult { OK, UNKNOWN, ALREADY_OWNED, MISSING_REQUIREMENT, INSUFFICIENT_FUNDS, FAILED }

var _catalog: UpgradeCatalog
var _owned: PackedStringArray = []


func _init(catalog: UpgradeCatalog, owned: Array = []) -> void:
	_catalog = catalog
	for upgrade_id: Variant in owned:
		if _catalog.get_definition(str(upgrade_id)) != null and not _owned.has(str(upgrade_id)):
			_owned.append(str(upgrade_id))


func get_catalog() -> UpgradeCatalog:
	return _catalog


func is_owned(upgrade_id: String) -> bool:
	return _owned.has(upgrade_id)


## Sum of all owned bonuses for a stat.
func get_bonus(stat: String) -> int:
	var total: int = 0
	for upgrade_id: String in _owned:
		var definition: UpgradeDefinition = _catalog.get_definition(upgrade_id)
		if definition != null and definition.stat == stat:
			total += definition.bonus
	return total


## Checks whether an upgrade could be bought right now.
func check_purchase(upgrade_id: String, wallet: Wallet) -> PurchaseResult:
	var definition: UpgradeDefinition = _catalog.get_definition(upgrade_id)
	if definition == null:
		return PurchaseResult.UNKNOWN
	if is_owned(upgrade_id):
		return PurchaseResult.ALREADY_OWNED
	if not definition.requires.is_empty() and not is_owned(definition.requires):
		return PurchaseResult.MISSING_REQUIREMENT
	if not wallet.can_afford(definition.price):
		return PurchaseResult.INSUFFICIENT_FUNDS
	return PurchaseResult.OK


## Pays and grants the upgrade. Nothing changes unless the payment succeeded.
func purchase(upgrade_id: String, wallet: Wallet) -> PurchaseResult:
	var check_result: PurchaseResult = check_purchase(upgrade_id, wallet)
	if check_result != PurchaseResult.OK:
		return check_result
	var definition: UpgradeDefinition = _catalog.get_definition(upgrade_id)
	if definition.price > 0:
		var payment: Wallet.Result = wallet.debit(definition.price, "upgrade-" + upgrade_id,
			"ui.ledger.upgrade")
		if payment == Wallet.Result.INSUFFICIENT_FUNDS:
			return PurchaseResult.INSUFFICIENT_FUNDS
		if payment != Wallet.Result.OK:
			return PurchaseResult.FAILED
	_owned.append(upgrade_id)
	upgrade_purchased.emit(definition)
	return PurchaseResult.OK


func to_save_data() -> Array:
	return Array(_owned)
