@tool
extends BTCondition

# Task parameters.
@export var variable_name : String
@export var threshold : int = 1
@export var set_to_0 : bool = true
# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return str("check ", variable_name)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if agent.logic_variables.has(variable_name):
		if agent.logic_variables[variable_name] >= threshold:
			return SUCCESS
	elif set_to_0:
		agent.logic_variables[variable_name] = 0
	return FAILURE


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
