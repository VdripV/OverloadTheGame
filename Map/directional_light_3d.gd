extends Light3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shadow_enabled = ProjectSettings.get_setting("global/Shadows_Enabled")
