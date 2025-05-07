@tool
extends "res://maps/base_map.gd"

@onready var elevator_target_array = [$ObstacleCourse/Elevator/Target1, $ObstacleCourse/Elevator/Target2]
var elevator_target_array_current:int = 1
var elevator_target_array_previous:int = 0

const PROGRESS_SECS = 2.5
@export_range(0.0, PROGRESS_SECS) var elevator_progress = 0.0

func next_elev_target():
    elevator_target_array_previous = elevator_target_array_current
    elevator_target_array_current += 1
    if elevator_target_array_current > elevator_target_array.size()-1:
        elevator_target_array_current = 0
func _physics_process(delta: float) -> void:
    var current_target:Marker3D = elevator_target_array[elevator_target_array_current]
    var previous_target:Marker3D = elevator_target_array[elevator_target_array_previous]

    if not Engine.is_editor_hint():
        elevator_progress += delta

    if elevator_progress > PROGRESS_SECS:
        elevator_progress = 0.0
        next_elev_target()
        current_target = elevator_target_array[elevator_target_array_current]
        previous_target = elevator_target_array[elevator_target_array_previous]

    $ObstacleCourse/Elevator.global_position = previous_target.global_position.lerp(current_target.global_position, elevator_progress/PROGRESS_SECS)

    # if $ObstacleCourse/Elevator.global_position.is_equal_approx(current_target.global_position):
    #     next_elev_target()
    #     current_target = elevator_target_array[elevator_target_array_current]
    
    # $ObstacleCourse/Elevator.velocity = global_position.lerp(current_target.global_position, 0.5)
    # $ObstacleCourse/Elevator.move_and_slide()
    