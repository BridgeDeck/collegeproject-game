@tool
extends Control

@export_range(0.05, 1.0, 0.01) var progress = 0.05 : set=set_progress
@export var loading_text:String : set=set_loading_text, get=get_loading_text

func set_progress(value):
	if ! is_node_ready():
		await ready
	progress = value
	$Container/LoadingBar/LoadedBar.anchor_right = clampf(progress, 0.05, 1.0)

func get_loading_text():
	return $Container/LoadingInfo.text
func set_loading_text(value):
	if ! is_node_ready():
		await ready
	$Container/LoadingInfo.text = value
