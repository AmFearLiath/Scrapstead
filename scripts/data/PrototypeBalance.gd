class_name PrototypeBalance
extends Resource
## Central balancing values of the gameplay prototype that are not part of an
## item or upgrade definition.

## Carry slots before any upgrade.
@export_range(1, 64) var base_carry_capacity: int = 4
## Credits at the start of a new game.
@export_range(0, 1000000) var starting_credits: int = 0
## Number of wallet transactions kept for display and diagnostics.
@export_range(1, 200) var ledger_size: int = 20
