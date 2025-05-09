extends Control

func _ready() -> void:
	$Buttons/Play.pressed.connect(_on_playbutton_pressed)

# Nothing much happens here, just load the tutorial map when "Play" is pressed
func _on_playbutton_pressed():
	MapHandler.load_map_by_path("res://maps/tutorial.tscn")