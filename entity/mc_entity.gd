extends Entity
class_name MainCharacterEntity

@export var max_dash_allowance:float = 1.0

## Dash regen per second
@export var dash_regeneration:float = 0.75

@export var dash_duration:float = 0.2
@export var dash_speed:float = 18*2

var dash_allowance:float = max_dash_allowance

var current_dash_duration:float = 0.0
var current_dash_direction:Vector3 = Vector3()

var prevdash_duration:float = 0.0

const FLAG_DASH = 1<<5

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

func _physics_process(delta: float) -> void:
	var true_previous_action = action_previous
	super._physics_process(delta)
	action_previous = true_previous_action
	if (action_previous & FLAG_DASH) != FLAG_DASH \
		and (action & FLAG_DASH) == FLAG_DASH \
		and dash_allowance >= 1.0:
		dash_allowance -= 1.0
		current_dash_duration = dash_duration
		current_dash_direction = force.normalized()
	else:
		dash_allowance = clampf(dash_allowance + dash_regeneration * delta, 0.0, max_dash_allowance)
	
	if current_dash_duration > 0.0 and !is_zero_approx(current_dash_duration):
		prevdash_duration = current_dash_duration
		current_dash_duration -= delta
		velocity = current_dash_direction.normalized() * dash_speed
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		
	elif prevdash_duration > 0.0 and !is_zero_approx(prevdash_duration):
		prevdash_duration = 0.0
		velocity = Vector3()
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		current_dash_direction = Vector3()
	
	action_previous = action

