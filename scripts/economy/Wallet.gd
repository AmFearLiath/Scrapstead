class_name Wallet
extends RefCounted
## Central credit account of the session. Every change is a validated, uniquely
## identified transaction; the balance can never become negative and the same
## transaction ID is never booked twice.

## Emitted after every booked transaction. `delta` is signed.
signal balance_changed(balance: int, delta: int, reason_key: String)

enum Result { OK, INVALID_AMOUNT, INSUFFICIENT_FUNDS, DUPLICATE }

var _balance: int = 0
var _sequence: int = 0
var _ledger: Array[Dictionary] = []
var _ledger_size: int = 20


func _init(balance: int = 0, sequence: int = 0, ledger: Array = [], ledger_size: int = 20) -> void:
	_balance = maxi(0, balance)
	_sequence = maxi(0, sequence)
	_ledger_size = ledger_size
	for entry: Variant in ledger:
		if typeof(entry) == TYPE_DICTIONARY and entry.has("id") and entry.has("amount"):
			_ledger.append({"id": str(entry["id"]), "amount": int(entry["amount"]),
				"reason": str(entry.get("reason", ""))})


func get_balance() -> int:
	return _balance


## Reserves a new, unique transaction ID (e.g. for a sale quote).
func next_transaction_id(prefix: String) -> String:
	_sequence += 1
	return "%s-%d" % [prefix, _sequence]


## Books income. `amount` must be positive.
func credit(amount: int, transaction_id: String, reason_key: String) -> Result:
	if amount <= 0:
		return Result.INVALID_AMOUNT
	return _book(amount, transaction_id, reason_key)


## Books an expense. Fails without change if the balance is insufficient.
func debit(amount: int, transaction_id: String, reason_key: String) -> Result:
	if amount <= 0:
		return Result.INVALID_AMOUNT
	return _book(-amount, transaction_id, reason_key)


func can_afford(amount: int) -> bool:
	return amount >= 0 and amount <= _balance


## True if a transaction with this ID is in the retained ledger.
func was_booked(transaction_id: String) -> bool:
	for entry: Dictionary in _ledger:
		if entry["id"] == transaction_id:
			return true
	return false


## Most recent transactions, newest last (copies).
func get_ledger() -> Array[Dictionary]:
	return _ledger.duplicate(true)


## Plain data for the save snapshot.
func to_save_data() -> Dictionary:
	return {"balance": _balance, "sequence": _sequence, "ledger": _ledger.duplicate(true)}


func _book(signed_amount: int, transaction_id: String, reason_key: String) -> Result:
	if transaction_id.is_empty():
		return Result.INVALID_AMOUNT
	if was_booked(transaction_id):
		return Result.DUPLICATE
	if _balance + signed_amount < 0:
		return Result.INSUFFICIENT_FUNDS
	_balance += signed_amount
	_ledger.append({"id": transaction_id, "amount": signed_amount, "reason": reason_key})
	while _ledger.size() > _ledger_size:
		_ledger.pop_front()
	balance_changed.emit(_balance, signed_amount, reason_key)
	return Result.OK
