@tool
extends BTAction

# Task parameters.
@export var interactable_type : interactable.item_type = interactable.item_type.CHEESE
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("dropping ", interactable_type)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.player_control.grabbing:
		if agent.player_control.grabbing.type == interactable_type:
			var item : Node3D = agent.player_control.grabbing
			item.drop()
			agent.player_control.grabbing = null
			item.global_position = Vector3(0,1000,0)
			return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
