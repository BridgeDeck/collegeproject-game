extends Entity
class_name MainCharacterEntity

const FLAG_DASH = 1<<5

static func generate_player_action_flag(jump:bool,
	crouch:bool,
	action1:bool,
	action2:bool,
	action3:bool,
    dash:bool
):
    var flags = Entity.generate_action_flag(jump, crouch, action1, action2, action3)

    if dash:
        flags = flags | FLAG_DASH
    
    return flags
