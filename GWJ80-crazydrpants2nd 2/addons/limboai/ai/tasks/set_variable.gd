@tool
extends BTAction

# Task parameters.
@export var variable_name : String
@export var new_value: int = 100
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("set ", variable_name, " ", new_value)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.logic_variables[variable_name] = new_value
	return SUCCESS

# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
