extends Control

func _ready() -> void:
	$Buttons/Play.pressed.connect(_on_playbutton_pressed)

func _on_playbutton_pressed():
	MapHandler.load_map_by_path("res://maps/base_map.tscn")