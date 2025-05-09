### An entity that is meant to be the one and only thing a player should control

extends Entity
class_name MainCharacterEntity

@export var base_jump_force:float = 18.0

## The maximum amount of dashes this entity can do at once
@export var max_dash_allowance:float = 1.0

## Dash regen per second
@export var dash_regeneration:float = 0.75

## Duration of a dash
@export var dash_duration:float = 0.05

## The constant speed this entity goes at while dashing
@export var dash_speed:float = 18*2

## The constant speed this entity goes at while slamming
@export var slam_speed:float = 80.0

## Used to indicate that this entity is slamming, and in what direction
@export_storage var current_slam_direction:Vector3 = Vector3()

@export var slam_bounce_degrade:float = 10.0
var slam_bounce:float = 0.0

## An allowance of dashes that will deplete and regenerate as this entity dashes, or does anything else that depletes the allowance.
var dash_allowance:float = max_dash_allowance

## Used to indicate this entity is dashing, and how much time it has left.
var current_dash_duration:float = 0.0

## Used to indicate the direction of the dash, should only be changed at the beginning of a dash and not in the middle of it unless necessary.
var current_dash_direction:Vector3 = Vector3()

## The duration of the dash in the previous frame before `current_dash_duration`
var prevdash_duration:float = 0.0

const FLAG_DASH = 1<<5

## Generate an action flag for this entity
## uses `generate_action_flag` internally, with some things added on top.
static func generate_player_action_flag(jump:bool,
	crouch:bool,
	action1:bool,
	action2:bool,
	action3:bool,
	dash:bool
):
	var flags = Entity.generate_action_flag(jump, crouch, action1, action2, action3)

	if dash:
		flags = flags | FLAG_DASH
	
	return flags

func _ready() -> void:
	super._ready()
	dash_allowance = max_dash_allowance

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if slam_bounce > base_jump_force:
		jump_force = slam_bounce
	else:
		jump_force = base_jump_force

	if (not ((action_previous & FLAG_JUMP) == FLAG_JUMP)) \
		and ((action & FLAG_JUMP) == FLAG_JUMP) \
		and jump_count > 0 \
		and can_jump():
		slam_bounce = 0.0

	# Do all the standard entity physics stuff BEFORE doing more player based things
	_entity_physics_process(delta)

	# Handle dashing
	if (action_previous & FLAG_DASH) != FLAG_DASH \
		and (action & FLAG_DASH) == FLAG_DASH \
		and dash_allowance >= 1.0:
		dash_allowance -= 1.0
		
		current_dash_duration = dash_duration
		current_dash_direction = force.normalized()

		current_slam_direction = Vector3.ZERO # Also cancel slamming

	else: # If not dashing, just regenerate the allowance
		dash_allowance = clampf(dash_allowance + dash_regeneration * delta, 0.0, max_dash_allowance)
	
	# If dashing, apply a constant horizontal force, cancel any vertical force and assume this body is floating
	if current_dash_duration > 0.0 and !is_zero_approx(current_dash_duration):
		prevdash_duration = current_dash_duration
		current_dash_duration -= delta
		velocity = current_dash_direction.normalized() * dash_speed
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

	# Applies at the end of a dash, ground the body again, apply the max horizontal force possible and reset dash stuff
	elif prevdash_duration > 0.0 and !is_zero_approx(prevdash_duration):
		prevdash_duration = 0.0
		velocity = force
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		current_dash_direction = Vector3()

	# If crouching midair, start slamming
	if (action_previous & FLAG_CROUCH) != FLAG_CROUCH \
		and (action & FLAG_CROUCH) == FLAG_CROUCH \
		and not is_on_floor():
			current_slam_direction = -up_direction
			slam_bounce = 0
	
	# Handle slamming
	if not current_slam_direction.is_zero_approx():
		if is_on_floor(): # Stop slamming once on floor
			current_slam_direction = Vector3()
		else: # Otherwise apply constant force towards the slam direction aswell as adding slam_bounce
			velocity = current_slam_direction * slam_speed
			slam_bounce += slam_speed * delta
		
	else: # If not slamming, just do crouching as normal and start degrading the slam bounce
		slam_bounce = move_toward(slam_bounce, 0, slam_bounce_degrade*delta)
		_entity_crouch_checking(delta)
	
	move_and_slide()

	action_previous = action

