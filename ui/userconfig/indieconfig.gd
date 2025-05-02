@tool
extends Node
class_name IndieConfig

signal property_changed(group:String, key:String)
signal property_added(group:String, key:String)
signal cleared_properties

enum IndieConfigValueType
{
	STRING,
	NUMBER,
	BOOLEAN,
	ENUM
}


class IndieConfigCheckerResult:
	var error_occured:bool
	var error_message:String
	
	var set_to

var config_ui:Control

@export_storage var configuration_data:Dictionary = {}
var configuration_metadata:Array = []

func init_path(group:String, key:String):
	if not configuration_data.has(key):
		configuration_data.set(group, {})
	
	if not configuration_data[group].has(key):
		configuration_data[group].set(key, null)

func set_value(group:String, key:String, value=null):
	var md = get_metadata(group, key)
	if md == null:
		return
	
	var valuetype:IndieConfigValueType = md.valuetype
	
	if value == null:
		configuration_data[group][key] = null
		return
	
	if valuetype == IndieConfigValueType.STRING:
		configuration_data[group][key] = str(value)
	elif valuetype == IndieConfigValueType.NUMBER:
		var set_num:float = clampf(float(value), md.num_minimum, md.num_maximum)
		
		configuration_data[group][key] = set_num
	elif valuetype == IndieConfigValueType.BOOLEAN:
		configuration_data[group][key] = bool(value)
	elif valuetype == IndieConfigValueType.ENUM:
		var set_enum = str(value)
		if not (set_enum in md.enum_values):
			configuration_data[group][key] = set_enum

	property_changed.emit(group, key)
	
	
func get_value(group:String, key:String):
	var md = get_metadata(group, key)
	if md == null:
		return
	
	if configuration_data[group][key] == null:
		return md.default
	else:
		return configuration_data[group][key]

func get_metadata(group:String, key:String)->IndieConfigMetadata:
	for _md in configuration_metadata:
		var md:IndieConfigMetadata = _md
		if md.group == group and md.key == key:
			return md
	return null

## Clears all data and metadata of this config
func clear():
	for _md in configuration_metadata:
		var md:IndieConfigMetadata = _md
		configuration_data[md.group][md.key] = null
	configuration_metadata.clear()
	cleared_properties.emit()

func add_config_string(default:String,
	group:String, 
	key:String, 
	display:String, 
	tooltip:String="",
	multiline:bool=false):
	var meta:IndieConfigMetadata = IndieConfigMetadata.new()
	meta.valuetype = IndieConfigValueType.STRING
	meta.default = default
	meta.group = group
	meta.key = key
	meta.display = display
	meta.tooltip = tooltip
	meta.string_multiline = multiline
	
	init_path(meta.group, meta.key)
	
	configuration_metadata.append(IndieConfigMetadata)

	property_added.emit(group, key)
	
func add_config_number(default:float, 
	group:String, 
	key:String, 
	display:String, 
	tooltip:String="",
	minimum:float=-9999999, 
	maximum:float=9999999, 
	snap:float=0.01):
	var meta:IndieConfigMetadata = IndieConfigMetadata.new()
	meta.valuetype = IndieConfigValueType.NUMBER
	meta.default = default
	meta.group = group
	meta.key = key
	meta.display = display
	meta.tooltip = tooltip
	meta.num_minimum = minimum
	meta.num_maximum = maximum
	meta.num_snap = snap
	
	init_path(meta.group, meta.key)
	
	configuration_metadata.append(IndieConfigMetadata)

	property_added.emit(group, key)
	
func add_config_boolean(
	default:bool, 
	group:String, 
	key:String, 
	display:String, 
	tooltip:String=""
):
	var meta:IndieConfigMetadata = IndieConfigMetadata.new()
	meta.valuetype = IndieConfigValueType.BOOLEAN
	meta.default = default
	meta.group = group
	meta.key = key
	meta.display = display
	meta.tooltip = tooltip
	
	init_path(meta.group, meta.key)
	
	configuration_metadata.append(IndieConfigMetadata)
	
	property_added.emit(group, key)

func add_config_enum(
	default:String,
	group:String,
	key:String,
	display:String,
	tooltip:String="",
	enum_values:PackedStringArray=[]
):
	var meta:IndieConfigMetadata = IndieConfigMetadata.new()
	meta.valuetype = IndieConfigValueType.ENUM
	meta.default = default
	meta.group = group
	meta.key = key
	meta.display = display
	meta.tooltip = tooltip
	meta.enum_values = enum_values
	
	if not (meta.default in meta.enum_values):
		meta.default = meta.enum_values[0]
	
	init_path(meta.group, meta.key)
	
	configuration_metadata.append(IndieConfigMetadata)
	
func _enter_tree() -> void:
	config_ui = preload("res://ui/userconfig/configuration_ui.tscn").instantiate()
	add_child(config_ui)
	
