extends NPC

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time < 255.0:
		start_dialogue("jaws_in_room")
		return

	if Globals.current_time > 255.0 and Globals.current_time < 300.0:
		start_dialogue("jaws_watches_news")
		return

	if Globals.current_time > 300.0 and Globals.current_time < 480.0:
		start_dialogue("jaws_outside_room")
		return
	
	if Globals.current_time > 480.0 and gamestate.SABOTAGED:
		start_dialogue("jaws_realizes_sabotage")
		return

	if Globals.current_time > 480.0 and gamestate.NORMAL:
		start_dialogue("jaws_files_safe")
		return
