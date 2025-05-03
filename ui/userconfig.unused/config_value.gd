@tool
extends Panel
class_name IndieConfigUiConfigValue

signal changed(node)

var default
var value : set=set_value, get=get_value 

var group:String
var key:String

var disabled : set=set_disabled, get=is_disabled

func set_disabled(value):
	pass

func is_disabled():
	return true

func set_value(value):
	changed.emit(self)

func get_value():
	pass
