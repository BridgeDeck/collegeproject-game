@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	$IndieConfig.add_config_boolean(false, "General", "allow_autosave", "Autosave", "Allows for autosaving")
	$IndieConfig.add_config_string("Freeman", "General", "player_name", "Name", "Your name displayed ingame", false)
	$IndieConfig.add_config_number(5, "General", "mouse_sensitivity", "Sensitivity", "The sensitivity of the mouse", 0.01, 100)
	$IndieConfig.add_config_enum("", "General", "preference", "Your Preference", "Choose wisely", PackedStringArray([
		"Boobs",
		"Ass"
	]))
