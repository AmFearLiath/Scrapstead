class_name ProcessingProfile
extends Resource
## One optional processing recipe (P1b): a single input item turns into at most
## two outputs after a visible effort. Direct sale of the input stays possible.

@export var id: String = ""
@export var input_item: ItemDefinition
## At most two outputs (mvp-prototype-plan.md, P1b).
@export var outputs: Array[ItemDefinition] = []
## Hold duration at the station in seconds (the visible effort).
@export_range(0.5, 20.0) var seconds: float = 3.5


## Sum of the direct-sale values of all outputs.
func get_output_value() -> int:
	var total: int = 0
	for output: ItemDefinition in outputs:
		total += output.sell_value
	return total


## Carry slots the outputs need in total.
func get_output_size() -> int:
	var total: int = 0
	for output: ItemDefinition in outputs:
		total += output.carry_size
	return total
