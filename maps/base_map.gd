@tool
extends Node3D
class_name BaseMap

func get_camera()->Camera3D:
	return $Camera3D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	get_camera().make_current()
	LocalPlayer.player_camera_state = LocalPlayer.PlayerCameraState.PLAYER_SPECTATOR
	LocalPlayer.player_camera = get_camera()
	
	LocalPlayer.player_camera_state = LocalPlayer.PlayerCameraState.PLAYER_FIRST_PERSON
	LocalPlayer.controlled_entity = $MainCharacterEntity

	
