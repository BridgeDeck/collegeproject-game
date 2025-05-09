## Autoload for handling the Main Menu only

extends Node

var node_main_menu:Control

func _enter_tree() -> void:
	node_main_menu = preload("res://ui/main_menu/main_menu.tscn").instantiate()
	add_child(node_main_menu)
	node_main_menu.visible = false

	# get_tree().root.ready.connect(_on_root_ready, CONNECT_ONE_SHOT)


func _process(delta: float) -> void:
	# This autoloads only purpose: to check if nothing else important is being displayed so it can display the main menu.
	# THis autoload is the ultimate fallback option
	var should_be_visible = true
	
	if Engine.is_editor_hint():
		should_be_visible = false

	if MapHandler.current_map != null:
		should_be_visible = false
	
	node_main_menu.visible = should_be_visible
