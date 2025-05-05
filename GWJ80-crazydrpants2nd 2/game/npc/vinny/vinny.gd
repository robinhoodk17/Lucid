extends NPC

@export var letter : interactable

func finish_quest(quest_name : Globals.npc_names, help_or_sabotage : NPC.gamestate) -> void:
	if quest_name == Globals.npc_names.VINNY:
		logic_variables["quest_finished"] = 100
		current_gamestate = help_or_sabotage

func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.VINNY):
		Globals.quest_started(Globals.npc_names.VINNY)
		
	if Globals.current_time < 240.0:
		start_dialogue("vinny_and_queen")
		return

	if Globals.current_time > 240.0 and Globals.current_time < 300.0:
		start_dialogue("i_love_office_news")
		return

	if Globals.current_time > 300.0 and current_gamestate == gamestate.SABOTAGED:
		start_dialogue("how_could_this_happen")
		return

	if Globals.current_time > 480.0 and Globals.quest_status[Globals.npc_names.VINNY] < 1:
		start_dialogue("our_love_is_doomed")
		return
		
	if Globals.current_time > 300.0 and Globals.current_time < 480.0:
		if Globals.quest_status[Globals.npc_names.VINNY] < 1:
			Globals.quest_progress(Globals.npc_names.VINNY)
			letter.global_position = global_position - global_basis.z
			start_dialogue("please_deliver")
			return
		else:
			if Globals.quest_status[Globals.npc_names.VINNY] >= 100:
				start_dialogue("butterfly_council")
				return

	if Globals.current_time > 300.0 and Globals.current_time < 480.0 and Globals.quest_status[Globals.npc_names.VINNY] < 100 and Globals.quest_status[Globals.npc_names.VINNY] > 0:
		start_dialogue("its_too_late_romulus_cant_stop_us")
		
	if Globals.current_time > 300.0 and Globals.quest_status[Globals.npc_names.VINNY] >= 100:
		start_dialogue("were_running_away")
