extends NPC


func handle_dialogue_start(_player_controller : player_controller) -> void:
	if Globals.current_time < 480.0:
		start_dialogue("starting_race")


func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "start_race":
		Globals.change_scene("res://game/scenes/racetrack/racetrack.tscn")
