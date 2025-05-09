## An autoload dedicated to handling maps

@tool
extends Node

signal loaded_map(path)

var current_map:BaseMap

func _enter_tree() -> void:
	get_tree().root.ready.connect(_on_root_ready, CONNECT_ONE_SHOT)

func _on_root_ready():
	# If you are editing a map and then running it directly,
	# you should get all the benefits of MapHandler even if you did not navigate from the main menu to it.
	# So, if from the editor you F6-ed into a map scene to playtest it, this will make sure
	# MapHandler will still recognize you loaded a map, and do everything it would do normally
	if get_tree().current_scene is BaseMap:
		current_map = get_tree().current_scene
		loaded_map.emit(get_tree().current_scene.scene_file_path)

## Load a map directly by its path.
## May return ERR_CANT_ACQUIRE_RESOURCE if the scene file path is invalid.
func load_map_by_path(path:String)->int:
	if Engine.is_editor_hint(): 
		return 1
	var _scenefile = ResourceLoader.load(path)
	
	# Do nothing if the scene file could not be loaded or is not a PackedScene at all
	if _scenefile == null or !(_scenefile is PackedScene):
		return ERR_CANT_ACQUIRE_RESOURCE
	
	var scenefile:PackedScene =_scenefile
	
	if current_map != null:
		current_map.queue_free()
		current_map = null
	
	current_map = scenefile.instantiate()
	add_child(current_map)

	loaded_map.emit(path)

	return OK
