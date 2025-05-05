@tool
extends BTCondition

# Task parameters.
@export var early: float = 0.0
@export var late: float = 1800.0

## Note: Each method declaration is optional.
## At minimum, you only need to define the "_tick" method.


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "TimePeriod"

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if Globals.current_time < early or Globals.current_time > late:
		return FAILURE
	return SUCCESS


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
