@tool
extends BTCondition

# Task parameters.
@export var game_state : NPC.gamestate
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("check if NPC in state ", game_state)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.current_gamestate == game_state:
		return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
