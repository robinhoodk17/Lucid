@tool
extends BTCondition

# Task parameters.
@export var variable_name : String
@export var threshold : int = 100

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("check if ", variable_name, " >= ", threshold)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if !agent.logic_variables.has(variable_name):
		agent.logic_variables[variable_name] = 0

	if agent.logic_variables[variable_name] >= threshold:
		return SUCCESS
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
