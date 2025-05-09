extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body:Node3D):
	if not _body is Entity:
		return
	
	var entity:Entity = _body

	entity.velocity = global_basis.y 