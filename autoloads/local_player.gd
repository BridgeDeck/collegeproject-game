@tool
extends Node

signal player_camera_state_changed

const SPECTATOR_CAMERA_SPEED = 8

enum PlayerCameraState
{
	CUSTOM,
	DISABLED,
	PLAYER_FIRST_PERSON,
	PLAYER_THIRD_PERSON,
	PLAYER_SPECTATOR,
	MAP_CUTSCENE,
	MAP_LOOKAT,
}
var player_camera:Camera3D
var player_camera_state:PlayerCameraState = PlayerCameraState.DISABLED : set=set_player_camera_state
var controlled_entity:Entity

func _enter_tree() -> void:
	player_camera_state_changed.connect(_on_camera_state_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mevent:InputEventMouseMotion = event
		
		if Engine.is_editor_hint():
			return
		
		# Pan the camera when in spectator view or fps view
		if player_camera_state == PlayerCameraState.PLAYER_SPECTATOR or player_camera_state == PlayerCameraState.PLAYER_FIRST_PERSON:
			camera_lookaround(player_camera, mevent.relative, Vector3.UP, 8)

func _process(delta: float) -> void:
	
	if Engine.is_editor_hint():
		return
	
	# Move around the camera when in spectator view
	if player_camera_state == PlayerCameraState.PLAYER_SPECTATOR and player_camera != null:
		if Input.is_action_pressed("forward"):
			player_camera.position += (-player_camera.basis.z)*SPECTATOR_CAMERA_SPEED*delta
		if Input.is_action_pressed("backward"):
			player_camera.position += (player_camera.basis.z)*SPECTATOR_CAMERA_SPEED*delta
		if Input.is_action_pressed("strafe_left"):
			player_camera.position += (-player_camera.basis.x)*SPECTATOR_CAMERA_SPEED*delta
		if Input.is_action_pressed("strafe_right"):
			player_camera.position += (player_camera.basis.x)*SPECTATOR_CAMERA_SPEED*delta
	
	if player_camera_state == PlayerCameraState.PLAYER_FIRST_PERSON and player_camera!=null and controlled_entity != null:
		
		var v = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
		
		
		var action_flags = MainCharacterEntity.generate_player_action_flag(
			Input.is_action_pressed("jump"),
			Input.is_action_pressed("crouch"),
			Input.is_action_pressed("action1"),
			Input.is_action_pressed("action2"),
			Input.is_action_pressed("action3"),
			Input.is_action_pressed("dash")
		)

		## TODO Add function to equip different items
		var equipped = -1

		controlled_entity.player_input(v, player_camera.basis, action_flags, equipped)
		#controlled_entity.force = (player_camera.basis * Vector3(v.x, 0, v.y)).normalized().slide(Vector3.UP) * 18
		# controlled_entity.add_force((player_camera.basis * Vector3(v.x, 0, v.y)).slide(Vector3.UP).normalized(), true)
		
		player_camera.position = controlled_entity.get_node("LookFrom").global_position
		#player_camera.look_at(controlled_entity.get_node("LookAt").position, controlled_entity.up_direction)
	

func set_player_camera_state(value):
	player_camera_state = value
	if player_camera_state == PlayerCameraState.DISABLED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	player_camera_state_changed.emit()

func _on_camera_state_changed():
	pass
func _on_map_loaded():
	player_camera = MapHandler.current_map.get_camera()

# made it its own function to avoid duplication
static func camera_lookaround(camera:Camera3D, 
	player_input:Vector2, 
	up_direction:Vector3,
	sensitivity:float):
	
	const MINIMUM_ANGLE_TO_ABSOLUTE_UPDOWN = deg_to_rad(10)
	const NORMALIZER = 0.001

	camera.rotate(up_direction, -player_input.x * sensitivity * NORMALIZER)
	camera.rotate_object_local(Vector3.LEFT, player_input.y * sensitivity * NORMALIZER)

	camera.global_basis = Basis.looking_at(-camera.global_basis.z, up_direction)

		
