@tool
extends SpotLight3D

@export_range(0.0, 1.0) var visual_light_transparency:float = 0.2

func _process(delta: float) -> void:
	# Make the Cone's height and position match that of the light
	$CSGCylinder3D.height = spot_range
	$CSGCylinder3D.position = Vector3(0,0,-$CSGCylinder3D.height/2)

	# Make the end of the cone match the radius of the spotlight based on `spot_angle`
	var cone_offset = Vector3(0,0,$CSGCylinder3D.height)
	cone_offset.y = Vector3(0,0,$CSGCylinder3D.height).rotated(Vector3.LEFT, deg_to_rad(spot_angle)).y
	$CSGCylinder3D.radius = cone_offset.y

	# Modulate various things to match the light color
	$CSGCylinder3D.material.albedo_color = light_color
	$CSGCylinder3D.material.albedo_color.a = visual_light_transparency
	$Sprite3D.modulate = light_color
