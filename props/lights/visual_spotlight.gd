@tool
extends SpotLight3D

@export_range(0.0, 1.0) var visual_light_transparency:float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CSGCylinder3D.height = spot_range
	$CSGCylinder3D.position = Vector3(0,0,-$CSGCylinder3D.height/2)
	var cone_offset = Vector3(0,0,$CSGCylinder3D.height)
	cone_offset.y = Vector3(0,0,$CSGCylinder3D.height).rotated(Vector3.LEFT, deg_to_rad(spot_angle)).y
	$CSGCylinder3D.radius = cone_offset.y
	$CSGCylinder3D.material.albedo_color = light_color
	$CSGCylinder3D.material.albedo_color.a = visual_light_transparency
	$Sprite3D.modulate = light_color
