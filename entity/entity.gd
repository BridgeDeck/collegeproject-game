extends CharacterBody3D
class_name  Entity

@export var target_goto_radius:float = 1.0

var abs_vert_direction:Vector3 = Vector3()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity_multiplier = 10

var force:Vector3

func add_force(applyforce:Vector3, vertical_only:bool):
	if vertical_only:
		applyforce = applyforce - (applyforce*up_direction)
	
	self.force  = applyforce * SPEED

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta 
	else:
		force = force - (force*up_direction)
	
	velocity.x = lerpf(velocity.x, force.x, 0.5)
	velocity.z = lerpf(velocity.z, force.z, 0.5)
	

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
