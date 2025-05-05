extends CharacterBody3D
class_name  Entity

const FLAG_JUMP = 1<<0
const FLAG_CROUCH = 1<<1
const FLAG_ACTION1 = 1<<2
const FLAG_ACTION2 = 1<<3
const FLAG_ACTION3 = 1<<4

@export var speed:float = 18
@export var jump_force:float = 8
@export var acceleration:float = 18*3
@export var air_speed_modifier:float = 1.0

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
	
	var modifiers = 1
	if not is_on_floor():
		modifiers -= air_speed_modifier
	
	# if not is_on_floor():
	# 	# infinite momentum
	# 	velocity = (velocity - velocity*up_direction) + (force.normalized() * acceleration*delta*modifiers) + velocity*up_direction
	# else: 
	# 	velocity = (velocity - velocity*up_direction).move_toward(force, acceleration*delta*modifiers) + velocity*up_direction
	velocity = (velocity - velocity*up_direction).move_toward(force, acceleration*delta*modifiers) + velocity*up_direction

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
