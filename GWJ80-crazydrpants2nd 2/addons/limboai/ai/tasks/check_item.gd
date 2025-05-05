@tool
extends BTCondition

# Task parameters.
@export var interactable_type : interactable.item_type = interactable.item_type.CHEESE
@export var timeline_name : String
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("grabbing ", interactable_type, " ", timeline_name)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.player_control.grabbing:
		if agent.player_control.grabbing.type == interactable_type:
			agent.start_dialogue(timeline_name)
			return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
