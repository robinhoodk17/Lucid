@tool
extends BTAction

# Task parameters.
@export var variable_name : String
@export var value : int = 100

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("set ", variable_name , " to ", value)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.logic_variables[variable_name] = value
	return SUCCESS

# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
