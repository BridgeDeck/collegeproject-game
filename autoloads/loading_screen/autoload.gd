@tool
extends Node

var screen:Control

var active:bool : set=set_active, get=get_active
var progress : set=set_progress, get=get_progress
var loading_text:String : set=set_loading_text, get=get_loading_text

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	screen = preload("res://autoloads/loading_screen/loading_screen.tscn").instantiate()
	add_child(screen)
	screen.ready.connect(_on_loading_screen_ready)

func _on_loading_screen_ready():
	screen.visible = false

func get_loading_text():
	return screen.loading_text
func set_loading_text(value):
	screen.loading_text = value

func set_progress(value):
	screen.progress = value
func get_progress():
	return screen.progress

func set_active(value):
	screen.visible = value
func get_active():
	return screen.visible
