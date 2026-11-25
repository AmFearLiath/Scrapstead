class_name UpgradeCatalog
extends Resource
## Ordered list of upgrades offered at the workbench.

@export var upgrades: Array[UpgradeDefinition] = []


func get_definition(upgrade_id: String) -> UpgradeDefinition:
	for definition: UpgradeDefinition in upgrades:
		if definition.id == upgrade_id:
			return definition
	return null
