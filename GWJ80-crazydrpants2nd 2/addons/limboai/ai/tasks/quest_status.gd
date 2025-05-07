@tool
extends BTCondition

# Task parameters.
@export var quest_name : Globals.npc_names = Globals.npc_names.CEE
@export var quest_progress : int = 1
## Note: Each method declaration is optional.
## At minimum, you only need to define the "_tick" method.


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("quest ", quest_name, " >= ", quest_progress)
# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if Globals.quest_status.has(quest_name):
		if Globals.quest_status[quest_name] >= quest_progress:
			return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
