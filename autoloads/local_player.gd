@tool
extends Node

## The camera state has changed
signal player_camera_state_changed

## Defalt spectator freecam speed
## TODO make some code where you can adjust the freecam speed using the mousewheel
const SPECTATOR_CAMERA_SPEED = 8

## Represents the different states a camera can be in
enum PlayerCameraState
{
	## No behavior, so the camera can be modified directly without the LocalPlayer autoload meddling
	CUSTOM, 

	## Represents that the camera is not available.
	## May be because there is no camera, or the camera is not the current one, or it has been disabled for now
	DISABLED,

	## Represents when the camera is following the player in first person
	PLAYER_FIRST_PERSON,
	
	## Represents when the camera is following the player in third person (Unused)
	PLAYER_THIRD_PERSON,

	## Represents when the camera is spectating in freecam
	PLAYER_SPECTATOR,

	## Unused
	MAP_CUTSCENE,

	## Unused
	MAP_LOOKAT,
}
## The current camera to be used by the player
var player_camera:Camera3D

## The current state/behavior of the camera.
var player_camera_state:PlayerCameraState = PlayerCameraState.DISABLED : set=set_player_camera_state , get=get_player_camera_state

## The entity that the local player wants to control.
var controlled_entity:Entity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mevent:InputEventMouseMotion = event
		
		if Engine.is_editor_hint():
			return
		
		# Pan the camera when in spectator view or fps view
		if player_camera_state == PlayerCameraState.PLAYER_SPECTATOR or player_camera_state == PlayerCameraState.PLAYER_FIRST_PERSON and player_camera != null:
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
	
	# If in first person, there is a camera being handled and an entity being controlled.
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
		
		player_camera.position = controlled_entity.get_node("LookFrom").global_position

func set_player_camera_state(value):
	player_camera_state = value
	if player_camera_state == PlayerCameraState.DISABLED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	player_camera_state_changed.emit()

func get_player_camera_state()->PlayerCameraState:
	# If the player camera does not exist or is not made current, consider disabled
	if player_camera == null:
		return PlayerCameraState.DISABLED
	elif not player_camera.current:
		return PlayerCameraState.DISABLED
		
	return player_camera_state


## Have a camera look around based on player input, the up direction and sensitivity
static func camera_lookaround(camera:Camera3D, 
	player_input:Vector2, 
	up_direction:Vector3,
	sensitivity:float):
	const NORMALIZER = 0.001

	camera.rotate(up_direction, -player_input.x * sensitivity * NORMALIZER)
	camera.rotate_object_local(Vector3.LEFT, player_input.y * sensitivity * NORMALIZER)

	camera.global_basis = Basis.looking_at(-camera.global_basis.z, up_direction)

		
