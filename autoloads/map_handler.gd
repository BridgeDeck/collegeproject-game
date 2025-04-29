@tool
extends Node

signal loaded_map(path)

var current_map:BaseMap


func load_map_by_path(path:String)->int:
	if Engine.is_editor_hint(): 
		return 1
	var scenefile:PackedScene = ResourceLoader.load(path)
	
	# Do nothing if the scene file could not be loaded or is not a PackedScene at all
	if scenefile == null or !(scenefile is PackedScene):
		return ERR_CANT_ACQUIRE_RESOURCE
	
	if current_map != null:
		current_map.queue_free()
		current_map = null
	
	current_map = scenefile.instantiate()
	add_child(current_map)

	loaded_map.emit(path)

	return OK
