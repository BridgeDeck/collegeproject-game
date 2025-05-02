@tool
extends Control

var node_indieconfig:IndieConfig : set=set_node_indieconfig

const PROP_STRING = preload("res://ui/userconfig/string_value.tscn")

func set_node_indieconfig(node):
	node_indieconfig = node
	
	node_indieconfig.property_added.connect(_on_property_added)
	node_indieconfig.property_changed.connect(_on_property_changed)
	node_indieconfig.cleared_properties.connect(_on_cleared_properties)

func regenerate():
	for _md in node_indieconfig.configuration_metadata:
		var md:IndieConfigMetadata = _md
		if md.valuetype == IndieConfig.IndieConfigValueType.STRING:
			$Properties/VBoxContainer.add_child(PROP_STRING.instantiate())

func _on_property_added():
	pass

func _on_property_changed():
	pass

func _on_cleared_properties():
	pass