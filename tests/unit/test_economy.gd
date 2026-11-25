extends TestSuite
## Wallet, CarryInventory and UpgradeProgress rules.

var _items: ItemCatalog
var _upgrades: UpgradeCatalog


func before_each() -> void:
	_items = load("res://data/items/item_catalog.tres")
	_upgrades = load("res://data/upgrades/upgrade_catalog.tres")


func test_catalog_data_is_valid() -> void:
	check(_items.validate().is_empty(), "item catalog valid: %s" % ", ".join(_items.validate()))
	check_eq(_items.items.size(), 7, "four P1 + three P1b item definitions")
	var loose: int = 0
	for definition: ItemDefinition in _items.items:
		check(definition.sell_value > 0, "%s has a value" % definition.id)
		check(not definition.name_key.is_empty() and tr(definition.name_key) != definition.name_key,
			"%s name is localized" % definition.id)
		if definition.category == "loose_scrap":
			loose += 1
	check(loose >= 2 and loose <= 3, "2-3 loose scrap definitions")
	check(_upgrades.get_definition("upgrade_carry_basket") != null, "carry upgrade defined")


func test_wallet_credit_debit_and_validation() -> void:
	var wallet := Wallet.new()
	var changes: Array = []
	wallet.balance_changed.connect(func(b: int, d: int, _r: String) -> void: changes.append([b, d]))
	check_eq(wallet.credit(25, "t1", "test"), Wallet.Result.OK, "credit ok")
	check_eq(wallet.get_balance(), 25, "balance after credit")
	check_eq(wallet.credit(25, "t1", "test"), Wallet.Result.DUPLICATE, "duplicate transaction rejected")
	check_eq(wallet.get_balance(), 25, "duplicate does not change balance")
	check_eq(wallet.debit(30, "t2", "test"), Wallet.Result.INSUFFICIENT_FUNDS, "overdraft rejected")
	check_eq(wallet.get_balance(), 25, "overdraft does not change balance")
	check_eq(wallet.credit(0, "t3", "test"), Wallet.Result.INVALID_AMOUNT, "zero credit rejected")
	check_eq(wallet.credit(-5, "t4", "test"), Wallet.Result.INVALID_AMOUNT, "negative credit rejected")
	check_eq(wallet.debit(-5, "t5", "test"), Wallet.Result.INVALID_AMOUNT, "negative debit rejected")
	check_eq(wallet.debit(25, "t6", "test"), Wallet.Result.OK, "exact debit ok")
	check_eq(wallet.get_balance(), 0, "balance zero, never negative")
	check_eq(changes.size(), 2, "only booked transactions emit")
	check(wallet.next_transaction_id("sale") != wallet.next_transaction_id("sale"), "unique ids")


func test_wallet_round_trip() -> void:
	var wallet := Wallet.new()
	wallet.credit(12, wallet.next_transaction_id("sale"), "ui.ledger.sale")
	var data: Dictionary = JSON.parse_string(JSON.stringify(wallet.to_save_data()))
	var restored := Wallet.new(int(data["balance"]), int(data["sequence"]), data["ledger"])
	check_eq(restored.get_balance(), 12, "balance restored")
	check(restored.was_booked("sale-1"), "ledger restored")
	check_eq(restored.next_transaction_id("sale"), "sale-2", "sequence continues, no id reuse")


func test_inventory_capacity_rules() -> void:
	var inventory := CarryInventory.new(_items, 4)
	check(inventory.add("a", "scrap_rusted_bolt"), "add small item")
	check(not inventory.add("a", "scrap_rusted_bolt"), "same object not twice")
	check(inventory.add("b", "scrap_wire_coil"), "add second")
	check(not inventory.add("c", "bulk_metal_beam"), "beam (3) does not fit into 2 free slots")
	check_eq(inventory.get_used_slots(), 2, "used slots")
	check(inventory.add("d", "scrap_empty_can"), "third")
	check(inventory.add("e", "scrap_empty_can"), "fourth fills basket")
	check(not inventory.add("f", "scrap_empty_can"), "full basket rejects")
	check(not inventory.add("g", "unknown_item"), "unknown item rejected")
	check_eq(inventory.get_last_object_id(), "e", "last picked")
	var revision: int = inventory.get_revision()
	check(inventory.remove("e"), "remove")
	check(inventory.get_revision() > revision, "revision increases on change")
	inventory.set_capacity(8)
	check(inventory.add("c", "bulk_metal_beam"), "beam fits after capacity increase")
	check_eq(inventory.get_used_slots(), 6, "beam counts 3 slots")
	var groups: Array[Dictionary] = inventory.get_grouped()
	check_eq(groups.size(), 4, "grouped by item type")


func test_upgrade_purchase_rules() -> void:
	var wallet := Wallet.new(20)
	var progress := UpgradeProgress.new(_upgrades)
	var price: int = _upgrades.get_definition("upgrade_carry_basket").price
	check_eq(progress.purchase("upgrade_carry_basket", wallet), UpgradeProgress.PurchaseResult.INSUFFICIENT_FUNDS,
		"too expensive")
	check(not progress.is_owned("upgrade_carry_basket"), "not owned after failed purchase")
	check_eq(wallet.get_balance(), 20, "no money taken on failure")
	wallet.credit(price, "top-up", "test")
	check_eq(progress.purchase("upgrade_carry_basket", wallet), UpgradeProgress.PurchaseResult.OK, "purchase ok")
	check_eq(wallet.get_balance(), 20, "price debited exactly once")
	check_eq(progress.get_bonus(UpgradeDefinition.STAT_CARRY_CAPACITY), 4, "bonus applied")
	check_eq(progress.purchase("upgrade_carry_basket", wallet), UpgradeProgress.PurchaseResult.ALREADY_OWNED,
		"no double purchase")
	check_eq(wallet.get_balance(), 20, "no second payment")
	check_eq(progress.purchase("nope", wallet), UpgradeProgress.PurchaseResult.UNKNOWN, "unknown upgrade")
	var restored := UpgradeProgress.new(_upgrades, ["upgrade_carry_basket", "ghost_upgrade"])
	check(restored.is_owned("upgrade_carry_basket"), "owned restored")
	check(not restored.is_owned("ghost_upgrade"), "unknown ids dropped on restore")


func test_localization_parity() -> void:
	# Every key must exist in en and de (Godot falls back to the key itself).
	var file := FileAccess.open("res://localization/scrapstead.csv", FileAccess.READ)
	var header: PackedStringArray = file.get_csv_line()
	check_eq(header, PackedStringArray(["keys", "en", "de"]), "csv header")
	var keys: Dictionary = {}
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 3 or row[0].is_empty():
			continue
		check(not keys.has(row[0]), "duplicate key " + row[0])
		keys[row[0]] = true
		check(not row[1].is_empty() and not row[2].is_empty(), "missing translation for " + row[0])
	check(keys.size() > 50, "keys loaded")
