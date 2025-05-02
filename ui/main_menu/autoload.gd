extends Node

var node_main_menu:Control

func _enter_tree() -> void:
	node_main_menu = preload("res://ui/main_menu/main_menu.tscn").instantiate()
	add_child(node_main_menu)
	
func _process(delta: float) -> void:
	# Check if any other important process is running,  otherwise, display main menu.
	if MapHandler.current_map != null:
		return
	
