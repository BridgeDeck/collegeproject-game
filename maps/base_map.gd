## Represents basic map functionality

@tool
extends Node3D
class_name BaseMap

# Get the default camera of the map
func get_camera()->Camera3D:
	return $Camera3D

func first_person(entity:Entity):
	LocalPlayer.controlled_entity = entity
	LocalPlayer.player_camera_state = LocalPlayer.PlayerCameraState.PLAYER_FIRST_PERSON
	LocalPlayer.player_camera = get_camera()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# default behavior, should be overridden according to the maps needs
	get_camera().make_current()
	first_person($MainCharacterEntity)

	
