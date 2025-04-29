@tool
extends Control

func _process(delta: float) -> void:
	const USEC = 1/1e-6
	
	var sincestart = Time.get_ticks_usec()/USEC
	
	$Sprite2D.rotation = (sin(sincestart)/2) * PI/10
