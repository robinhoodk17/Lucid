extends NPC

func extendable_ready() -> void:
	pass

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time < 360.0:
		start_dialogue("mee_looking_for_badge")
		return

	if Globals.current_time < 360.0:
		start_dialogue("mee_could_be_worse")
		return

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "mee_union":
		logic_variables["convinced_barry"] = 100
		Globals.quest_progress(Globals.npc_names.BARRY)
