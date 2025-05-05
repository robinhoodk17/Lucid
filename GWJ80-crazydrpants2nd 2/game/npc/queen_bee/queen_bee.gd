extends NPC

func extendable_ready() -> void:
	Globals.on_quest_progress.connect(quest_progressed)

func quest_progressed(quest_name : Globals.npc_names) -> void:
	if quest_name != Globals.npc_names.VINNY:
		return
	logic_variables["quest_progression"] -= 1
	if logic_variables["quest_progression"] == 0:
		current_gamestate = gamestate.HELPED
		Globals.quest_finished(Globals.npc_names.VINNY, gamestate.HELPED, 2)
	else:
		Globals.quest_progress(Globals.npc_names.VINNY)
		
func finish_quest(quest_name : Globals.npc_names, help_or_sabotage : NPC.gamestate) -> void:
	if quest_name == Globals.npc_names.VINNY:
		logic_variables["quest_finished"] = 100
		current_gamestate = help_or_sabotage
		quest_completed = true

func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.VINNY):
		Globals.quest_started(Globals.npc_names.VINNY)

	if Globals.current_time < 240.0:
		start_dialogue("vinny_and_queen")
		return
		
	if Globals.current_time > 240.0 and Globals.current_time < 300.0:
		start_dialogue("i_love_office_news_queen_bee")
		return

	if Globals.current_time > 300.0:
		if current_gamestate == gamestate.SABOTAGED:
			start_dialogue("how_could_this_happen_queen_bee")
			return

	if Globals.quest_status.has(Globals.npc_names.BARRY) and !logic_variables["convinced_barry_quest"]:
		start_dialogue("convince_queen")
		return
	
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.LETTER:
			if Globals.quest_status[Globals.npc_names.VINNY] == 1:
				Globals.quest_progress(Globals.npc_names.VINNY)
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				item.quest_finished = true
				start_dialogue("queen_bee_plan")
				logic_variables["waiting_plan"] = 100
				logic_variables["quest_progression"] = 2
				return
			else:
				start_dialogue("butterfly_council")
				return
	
	if logic_variables["waiting_plan"] and Globals.current_time > 360.0 and Globals.current_time < 480.0:
		start_dialogue("waiting_for_the_plan")
		return
	
	if logic_variables["waiting_plan"] and Globals.current_time > 480.0:
		start_dialogue("too_late_for_the_plan")
		return
		
	if Globals.current_time > 360.0 and current_gamestate == gamestate.HELPED and quest_completed and Globals.current_time < 480.0:
		start_dialogue("waiting_to_run_away")
		return

	if Globals.current_time > 480.0 and current_gamestate == gamestate.HELPED and quest_completed:
		start_dialogue("were_running_away")
		return


func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "queen_barry_quest":
		logic_variables["convinced_barry_quest"] = 100
		Globals.quest_progress(Globals.npc_names.BARRY)
