@tool
extends BTAction

# Task parameters.
@export var quest_name : Globals.npc_names
@export var gamestate : NPC.gamestate
@export var points : int = 1
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("progress ", quest_name)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	Globals.quest_finished(quest_name, gamestate, points)
	return SUCCESS

# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
