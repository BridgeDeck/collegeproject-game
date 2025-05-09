## Basic entity that is meant to move around the map and do things.


extends CharacterBody3D
class_name  Entity

# Flags representing basic actions an entity can do

const FLAG_JUMP = 1<<0
const FLAG_CROUCH = 1<<1
const FLAG_ACTION1 = 1<<2
const FLAG_ACTION2 = 1<<3
const FLAG_ACTION3 = 1<<4

## Walking speed (or default speed) of this entity
@export var walk_speed:float = 18

## How much force is applied upwards for this entity when it jumps
@export var jump_force:float = 8

## How much this entity should accelerate per second up to its maximum speed when it moves.
@export var acceleration:float = 18*3

## maximum amount of jumps this entity can perform. Resets when on the ground. 
@export var max_jump_count:int = 1

## Speed of this entity while crouched.
@export var crouch_speed:float = 9

## Ideal speed of this entity, changes based on events like whether the entity is crouching or not
var current_speed = 18

## The amount of jumps that this entity can do
## Usually resets to max_jump_count when on the floor
var jump_count:int = max_jump_count

## A flag representing the basic actions that this entity is doing
var action:int

## A flag representing the basic actions that this entity was doing in the previous physics frame
var action_previous:int

## The currently equipped item/weapon (UNUSED)
var equipped:int

## Current force applied to this entity
var force:Vector3

## applies a force to this entity to move.
## usually you only want an entity to move horizontally, which is what `horizontal_only` is for.
func add_force(applyforce:Vector3, horizontal_only:bool):
	if horizontal_only:
		applyforce = applyforce - (applyforce*up_direction)
	
	self.force  = applyforce * current_speed

## Method that takes the input player that is taking control of this entity and applies it as action flags, force, look direction and other things.
func player_input(
	movement_dir:Vector2,
	camera_basis:Basis,
	actionflags:int,
	equip:int
):
	action = actionflags
	var vertdirection = (camera_basis * Vector3(movement_dir.x, 0, movement_dir.y)).slide(up_direction).normalized()
	add_force(vertdirection,false)
	equipped = equip

	$LookAt.global_position = $LookFrom.global_position + -camera_basis.z

func _ready() -> void:
	# delete the CSGBoxes, they are only references
	if not Engine.is_editor_hint():
		$CrouchCollision/CSGBox3D.queue_free()
		$CrouchCollision/CSGBox3D.queue_free()

## Dedicated to applying crouching mechanics
func _entity_crouch_checking(_delta:float):
	#Crouching
	if (action & FLAG_CROUCH) == FLAG_CROUCH:
		$DefaultCollision.disabled = true
		$CrouchCollision.disabled = false
		$LookFrom.position = $LookFromCrouched.position
		current_speed = crouch_speed
	else:
		$DefaultCollision.disabled = false
		$CrouchCollision.disabled = true
		$LookFrom.position = $LookFromUncrouched.position
		current_speed = walk_speed

## Default entity physics process, only changes properties but you have to call move_and_slide manually afterwards.
func _entity_physics_process(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 
	else:
		velocity = velocity - (velocity*up_direction)
		jump_count = max_jump_count
	
	# May add movement modifiers in the future
	var modifiers = 1
	
	# Move entity around as normal on the floor
	if is_on_floor():
		velocity = (velocity - velocity*up_direction).move_toward(force, acceleration*delta*modifiers) + velocity*up_direction

	# If not on the floor, then you can still maneuver and glide through the air, but you cant increase your horizontal velocity.
	# the absolute minimum horizontal velocity you can have is around 1m/s
	elif not force.is_zero_approx():
		var current_hori_velocity = velocity - velocity*up_direction
		var next_hori_velocity = current_hori_velocity.move_toward(force, acceleration*delta*modifiers*2)
		var final_hori_velocity = Vector3()

		## TODO maybe change this to make sure the minimum is a flat 1.0 horizontal velocity, because sometimes it can be an awkward number like 1.27 or 3.2
		if next_hori_velocity.length() > current_hori_velocity.length() and current_hori_velocity.length() > 1:
			final_hori_velocity = current_hori_velocity
		else:
			final_hori_velocity = next_hori_velocity
		
		velocity = final_hori_velocity + velocity*up_direction

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

	# JUMPING
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

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_entity_crouch_checking(delta)
	_entity_physics_process(delta)

	move_and_slide()

	action_previous = action

## Overridable conditions for jumping
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
	
	if action1:
		flags = flags | FLAG_ACTION1
	
	if action2:
		flags = flags | FLAG_ACTION2
	
	if action3:
		flags = flags | FLAG_ACTION3

	return flags
