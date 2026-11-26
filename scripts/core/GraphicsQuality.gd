class_name GraphicsQuality
extends RefCounted
## Graphics quality presets (art style 2, docs/art-style-2.md).
##
## "high" is the look the game is designed for. "medium" drops indirect light
## (SSIL) and multisampling, "low" also drops ambient occlusion, glow and fog
## and uses smaller, harder shadows for weak GPUs and laptops. The setting is
## stored by GameSession; scenes call apply() when they start and whenever the
## setting changes. Environment resources are shared, so switching back to
## "high" restores every effect.

const LEVELS: PackedStringArray = ["low", "medium", "high"]
const DEFAULT: String = "high"


static func apply(scene_root: Node, quality: String) -> void:
	if not LEVELS.has(quality):
		quality = DEFAULT
	var high: bool = quality == "high"
	var low: bool = quality == "low"
	for node: Node in scene_root.find_children("*", "WorldEnvironment", true, false):
		var environment: Environment = (node as WorldEnvironment).environment
		if environment == null:
			continue
		environment.ssil_enabled = high
		environment.ssao_enabled = not low
		environment.glow_enabled = not low
		environment.fog_enabled = not low
	for node: Node in scene_root.find_children("*", "DirectionalLight3D", true, false):
		var sun := node as DirectionalLight3D
		sun.shadow_blur = 1.4 if not low else 0.6
		sun.directional_shadow_max_distance = 70.0 if high else (50.0 if not low else 35.0)
	var viewport: Viewport = scene_root.get_viewport()
	if viewport != null:
		viewport.msaa_3d = Viewport.MSAA_2X if high else Viewport.MSAA_DISABLED
		viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED if high else Viewport.SCREEN_SPACE_AA_FXAA
	RenderingServer.directional_shadow_atlas_set_size(4096 if high else (2048 if not low else 1024), true)
	var filter: RenderingServer.ShadowQuality = RenderingServer.SHADOW_QUALITY_SOFT_HIGH
	if quality == "medium":
		filter = RenderingServer.SHADOW_QUALITY_SOFT_LOW
	elif low:
		filter = RenderingServer.SHADOW_QUALITY_HARD
	RenderingServer.directional_soft_shadow_filter_set_quality(filter)
	RenderingServer.positional_soft_shadow_filter_set_quality(filter)
