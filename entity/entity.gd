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
@export var max_jump_count:int = 1

var jump_count:int = max_jump_count
var action_previous:int
var action:int
var equipped:int

var force:Vector3

# var previous_global_position:Vector3
# var previous_velocity:Vector3
# var walljump_impulse:Vector3

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
	equipped = equip

func _ready() -> void:
	if not Engine.is_editor_hint():
		$CrouchCollision/CSGBox3D.queue_free()
		$CrouchCollision/CSGBox3D.queue_free()

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
		jump_count = max_jump_count
	
	var modifiers = 1
	if not is_on_floor():
		modifiers -= air_speed_modifier
	
	# Cannot add momentum midair, but you can redirect it
	# if is_on_floor():
	velocity = (velocity - velocity*up_direction).move_toward(force, acceleration*delta*modifiers) + velocity*up_direction

	# a pathetic implementation of walljumping, do we even want wall jumping? or are midair jumps fine.
	# if (not is_on_floor()) and is_on_wall() and walljump_impulse.is_zero_approx():
	# 	var query = PhysicsRayQueryParameters3D.new()
	# 	query.from = previous_global_position
	# 	query.to = previous_global_position + ((previous_velocity-previous_velocity*up_direction).normalized() * speed)
	# 	query.collision_mask = 1<<0
	# 	query.exclude.append(self.get_rid())
	# 	var space = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	# 	var result = space.intersect_ray(query)
	# 	var result_normal:Vector3 = result.get("normal", Vector3())

	# 	if result_normal.max_axis_index() != Vector3.AXIS_Y:
	# 		walljump_impulse = result_normal * speed
	# else:
	# 	walljump_impulse = Vector3()

	# jumping
	# Check if previous action flags did not contain FLAG_JUMP
	# THEN check if current action flags do
	# THEN check if you can still use jumps
	# THEN check if you are even allowed to jump
	if (not ((action_previous & FLAG_JUMP) == FLAG_JUMP)) \
		and ((action & FLAG_JUMP) == FLAG_JUMP) \
		and jump_count > 0 \
		and can_jump():
		jump_count -= 1
		velocity = (velocity - (velocity*up_direction)) + up_direction * jump_force

		# if not walljump_impulse.is_zero_approx():
			# velocity = walljump_impulse + velocity*up_direction
			# walljump_impulse = Vector3()
	
	# previous_velocity = velocity
	move_and_slide()

	action_previous = action
	# previous_global_position = global_position

func can_jump()->bool:
	return is_on_floor() or (!is_on_floor() and is_on_wall())

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
