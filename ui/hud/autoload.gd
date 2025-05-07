extends Node

var hud_node:HudElements

func _enter_tree() -> void:
    hud_node = preload("res://ui/hud/hud_elements.tscn").instantiate()
    add_child(hud_node)
    hud_node.visible = false

func _process(delta: float) -> void:
    if LocalPlayer.controlled_entity \
    and (
            LocalPlayer.player_camera_state == LocalPlayer.PlayerCameraState.PLAYER_FIRST_PERSON \
            or LocalPlayer.player_camera_state == LocalPlayer.PlayerCameraState.PLAYER_THIRD_PERSON
        ):
        hud_node.visible = true

        var mc:MainCharacterEntity = LocalPlayer.controlled_entity
        hud_node.dash_allowance_indication_progress = mc.dash_allowance / mc.max_dash_allowance
        hud_node.dash_allowance_indication_minimum = 1/mc.max_dash_allowance
        hud_node.overall_velocity = mc.velocity.length()
        var vert_dir = (mc.velocity*mc.up_direction).normalized()
        var actual_vert_value = (mc.velocity*mc.up_direction).length()
        if not is_zero_approx(vert_dir.angle_to(mc.up_direction)):
            actual_vert_value = -actual_vert_value
        hud_node.vertical_velocity = actual_vert_value
        hud_node.horizontal_velocity = (mc.velocity - mc.velocity*mc.up_direction).length()
    else:
        hud_node.visible = false