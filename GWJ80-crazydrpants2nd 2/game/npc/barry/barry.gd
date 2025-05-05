extends NPC

func extendable_ready() -> void:
	Globals.on_quest_progress.connect(quest_progressed)

func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.BARRY):
		Globals.quest_started(Globals.npc_names.BARRY)

	if Globals.quest_status.has(Globals.npc_names.VINNY):
		if Globals.quest_status[Globals.npc_names.VINNY] > 1 and !logic_variables["convinced"]:
			start_dialogue("convince_barry")
			return	
	
	if random_talks <= 0:
		random_talks += 1
		logic_variables["quest_progression"] = 6
		Globals.quest_progress(Globals.npc_names.BARRY)
		start_dialogue("barry_asks_for_help")
		return
	
	if Globals.current_time < 420.0 and random_talks > 0 and Globals.quest_status[Globals.npc_names.BARRY] <100:
		if logic_variables["convinced"]:
			start_dialogue("still_need_approval")
			return
		else:
			start_dialogue("barry_waits_for_help")
			return
	
	if Globals.current_time < 420.0 and current_state == gamestate.HELPED:
		start_dialogue("confident_about_motion")
		return
		
	if Globals.current_time > 420.0 and !current_state == gamestate.HELPED:
		start_dialogue("motion_rejected")
		return
	
	if Globals.current_time > 420.0 and current_state == gamestate.HELPED:
		start_dialogue("better_working_conditions")
		return

func quest_progressed(quest_name : Globals.npc_names) -> void:
	if quest_name != Globals.npc_names.BARRY:
		return
	logic_variables["quest_progression"] -= 1
	if logic_variables["quest_progression"] == 0:
		Globals.quest_finished(Globals.npc_names.BARRY, gamestate.HELPED, 3)
		
		
func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "barry_queen_quest_success":
		Globals.quest_progress(Globals.npc_names.VINNY)
		logic_variables["convinced"] = true
