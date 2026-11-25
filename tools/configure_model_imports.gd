extends SceneTree
## Development tool: makes every Blender model in assets/models use the shared
## toon material instead of its exported placeholder material "Scrap".
##   godot --headless --path . --import
##   godot --headless --path . -s res://tools/configure_model_imports.gd
##   godot --headless --path . --import
## See docs/world-art-assets.md, section 5.

const MODEL_DIR: String = "res://assets/models"
const TOON_MATERIAL: String = "res://assets/materials/toon_vertex.tres"


func _init() -> void:
	var changed: int = 0
	for file_name: String in DirAccess.get_files_at(MODEL_DIR):
		if not file_name.ends_with(".glb.import"):
			continue
		var path: String = MODEL_DIR.path_join(file_name)
		var config := ConfigFile.new()
		if config.load(path) != OK:
			push_error("configure_model_imports: cannot read " + path)
			continue
		var subresources: Dictionary = config.get_value("params", "_subresources", {})
		var materials: Dictionary = subresources.get("materials", {})
		materials["Scrap"] = {
			"use_external/enabled": true,
			"use_external/path": TOON_MATERIAL,
		}
		subresources["materials"] = materials
		config.set_value("params", "_subresources", subresources)
		config.save(path)
		changed += 1
	print("configure_model_imports: %d model(s) configured" % changed)
	quit()
