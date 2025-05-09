@tool
extends Control
class_name HudElements

@export_range(0.0, 1.0) var dash_allowance_indication_progress:float = 1.0
@export_range(0.0, 1.0) var dash_allowance_indication_minimum:float = 0.5
@export_color_no_alpha var dash_allowance_indication_full:Color = Color(0.178, 0.997, 0.966)
@export_color_no_alpha var dash_allowance_indication_partial:Color = Color(0.971, 0.89, 0.0)
@export_color_no_alpha var dash_allowance_indication_invalid:Color = Color(0.851, 0.0, 0.132)

@export var overall_velocity:float = 0.0
@export var horizontal_velocity:float = 0.0
@export var vertical_velocity:float = 0.0

@export var health_max:float = 100
@export var health_current:float = 100

# Utility function for rounding to a decimal point, honestly Godot should add a builtin one.
static func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _process(delta: float) -> void:
	# Dont do anything if you are not visible
	if not visible:
		return

	$DashAllowanceIndication/ColorRect.anchor_right = dash_allowance_indication_progress

	# Color the dash indication stuff according to the percentage left
	$DashAllowanceIndication/Label.text = str(roundi(dash_allowance_indication_progress * 100.0)) + "%"
	if dash_allowance_indication_progress < dash_allowance_indication_minimum:
		$DashAllowanceIndication/ColorRect.color = $DashAllowanceIndication/ColorRect.color.lerp(dash_allowance_indication_invalid, 0.5)
		$DashAllowanceIndication/Label.add_theme_color_override("font_color", dash_allowance_indication_invalid)

	elif is_equal_approx(dash_allowance_indication_progress, 1.0): # Ordering matters!
		$DashAllowanceIndication/ColorRect.color = $DashAllowanceIndication/ColorRect.color.lerp(dash_allowance_indication_full, 0.1)
		$DashAllowanceIndication/Label.add_theme_color_override("font_color", dash_allowance_indication_full)

	elif dash_allowance_indication_progress > dash_allowance_indication_minimum:
		$DashAllowanceIndication/ColorRect.color = $DashAllowanceIndication/ColorRect.color.lerp(dash_allowance_indication_partial, 0.3)
		$DashAllowanceIndication/Label.add_theme_color_override("font_color", dash_allowance_indication_partial)

	# Add velocity numbers
	$Accelerometer/Overall/Value.text = str(absf(round_to_dec(overall_velocity, 2)))
	$Accelerometer/Horizontal/Value.text = str(absf(round_to_dec(horizontal_velocity, 2)))
	$Accelerometer/Vertical/Value.text = str(round_to_dec(vertical_velocity,2))

	# Add health
	health_current = clampf(health_current, 0, health_max) # Make sure current health does not surpass max
	$Healthbar/Bar.anchor_right = clampf(health_current/health_max, 0.03, 1.0)
	$Healthbar/MaxHealth.text = str(round_to_dec(health_max,2))
	$Healthbar/Bar/Label.text = str(round_to_dec(health_current,2))
    
    
