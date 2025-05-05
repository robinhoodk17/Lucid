@tool
extends BTAction

# Task parameters.
@export var quest_name : Globals.npc_names
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("progress ", quest_name)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	Globals.quest_progress(quest_name)
	return SUCCESS

# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
