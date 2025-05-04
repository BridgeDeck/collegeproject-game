extends CharacterBody3D
class_name  Entity

const FLAG_JUMP = 1<<0
const FLAG_CROUCH = 1<<1
const FLAG_ACTION1 = 1<<2
const FLAG_ACTION2 = 1<<3
const FLAG_ACTION3 = 1<<4

@export var speed:float = 18
@export var jump_force:float = 8
@export var acceleration:float = 2

var action_previous:int
var action:int
var equipped:int

var force:Vector3

func add_force(applyforce:Vector3, vertical_only:bool):
	if vertical_only:
		applyforce = applyforce - (applyforce*up_direction)
	
	self.force  = applyforce * speed

func player_input(
	movement_dir:Vector2,
	camera_basis:Basis,
	actionflags:int,
	equip:int
):
	action = actionflags
	add_force((camera_basis * Vector3(movement_dir.x, 0, movement_dir.y)).slide(up_direction).normalized(),false)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	#Crouching
	if (action & FLAG_CROUCH) == FLAG_CROUCH:
		$DefaultCollision.disabled = true
		$CrouchCollision.disabled = false
		$LookFrom.position = $LookFromCrouched.position
	else:
		$DefaultCollision.disabled = false
		$CrouchCollision.disabled = true
		$LookFrom.position = $LookFromUncrouched.position
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 
	else:
		velocity = velocity - (velocity*up_direction)
	
	# jumping
	# Check if previous action flags did not contain FLAG_JUMP and then check if current action flags do
	if (not ((action_previous & FLAG_JUMP) == FLAG_JUMP)) and ((action & FLAG_JUMP) == FLAG_JUMP):
		velocity = (velocity - (velocity*up_direction)) + up_direction * jump_force
	
	# velocity.x = lerpf(velocity.x, force.x, delta*Engine.physics_ticks_per_second/2.0)
	# velocity.z = lerpf(velocity.z, force.z, delta*Engine.physics_ticks_per_second/2.0)
	velocity = (velocity - velocity*up_direction).move_toward(force, acceleration*delta) + velocity*up_direction
	

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	action_previous = action

## Generate a bitflag int representing the different actions an entity can do
static func generate_action_flag(
	jump:bool,
	crouch:bool,
	action1:bool,
	action2:bool,
	action3:bool
)->int:
	var flags:int = 0

	if jump:
		flags = flags | FLAG_JUMP
	
	if crouch:
		flags = flags | FLAG_CROUCH
	
	# if dash:
	# 	flags = flags | FLAG_DASH
	
	if action1:
		flags = flags | FLAG_ACTION1
	
	if action2:
		flags = flags | FLAG_ACTION2
	
	if action3:
		flags = flags | FLAG_ACTION3

	return flags
