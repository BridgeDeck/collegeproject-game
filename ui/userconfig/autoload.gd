extends Node

var cfgfile:ConfigFile = ConfigFile.new()



func _enter_tree() -> void:
	cfgfile.load("user://userconfig.ini")

func _exit_tree() -> void:
	cfgfile.save("user://userconfig.ini")
