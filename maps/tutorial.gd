@tool
extends "res://maps/base_map.gd"

@onready var elevator_target_array = [$ObstacleCourse/Elevator/Target1, $ObstacleCourse/Elevator/Target2]
var elevator_target_array_current:int = 1
var elevator_target_array_previous:int = 0

const PROGRESS_SECS = 2.5

## Progress of the Elevator node between the first target and the previous
@export_range(0.0, PROGRESS_SECS) var elevator_progress = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	LocalPlayer.player_camera_state = LocalPlayer.PlayerCameraState.PLAYER_FIRST_PERSON
	LocalPlayer.controlled_entity = $MainCharacterEntity
	LocalPlayer.player_camera = $Camera3D

## Pick the next target for the Elevator
func next_elev_target():
	elevator_target_array_previous = elevator_target_array_current
	elevator_target_array_current += 1
	if elevator_target_array_current > elevator_target_array.size()-1:
		elevator_target_array_current = 0
func _physics_process(delta: float) -> void:
	var current_target:Marker3D = elevator_target_array[elevator_target_array_current]
	var previous_target:Marker3D = elevator_target_array[elevator_target_array_previous]

	# you can still update the elevator progress to move it in the editor, but will only update by itself in a non-editor environment
	if not Engine.is_editor_hint():
		elevator_progress += delta

	## Advance to next elevator target and refresh targets
	if elevator_progress > PROGRESS_SECS:
		elevator_progress = 0.0
		next_elev_target()
		current_target = elevator_target_array[elevator_target_array_current]
		previous_target = elevator_target_array[elevator_target_array_previous]

	# apply progress
	$ObstacleCourse/Elevator.global_position = previous_target.global_position.lerp(current_target.global_position, elevator_progress/PROGRESS_SECS)
