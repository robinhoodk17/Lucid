@tool
extends BTAction

# Task parameters.
@export var timeline : String

## Note: Each method declaration is optional.
## At minimum, you only need to define the "_tick" method.


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "dialogic_start"

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	agent.start_dialogue(timeline)
	return SUCCESS


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
