extends Node

var indieconfig:IndieConfig

func _enter_tree() -> void:
	indieconfig = IndieConfig.new()
	add_child(indieconfig)
