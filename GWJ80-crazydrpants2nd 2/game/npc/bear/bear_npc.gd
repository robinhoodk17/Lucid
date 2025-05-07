extends NPC

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if !logic_variables.has("convinced_barry_quest"):
		logic_variables["convinced_barry_quest"] = 0

	if !Globals.quest_status.has(Globals.npc_names.MAMA_BEAR):
		Globals.quest_started(Globals.npc_names.MAMA_BEAR)

	if Globals.quest_status.has(Globals.npc_names.BARRY) and !logic_variables["convinced_barry_quest"]:
		start_dialogue("mama_bear_barry_idea")
		return

	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.BADGE:
			if Globals.current_time > 360.0 and Globals.current_time < 480.0:
				start_dialogue("mama_bear_mee_badge")
				Globals.quest_finished(Globals.npc_names.MEE, gamestate.SABOTAGED, -1)
				var item : Node3D = _player_controller.grabbing
				item.drop()
				item.quest_finished = true
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return

			if Globals.current_time < 360.0:
				start_dialogue("mama_bear_too_early")
				return
			
			if Globals.current_time > 480.0:
				start_dialogue("mama_bear_no_overtime")
				return

	if Globals.quest_status[Globals.npc_names.MAMA_BEAR] <100:
		start_dialogue("mama_bear_decision_tree")
		return
	else:
		start_dialogue("mama_bear_correct_choices")
		return



func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "mama_bear_barry_quest":
		logic_variables["convinced_barry_quest"] = 100
		Globals.quest_progress(Globals.npc_names.BARRY)		

	if signal_argument == "mama_bear_quest_finished":
		Globals.quest_finished(Globals.npc_names.MAMA_BEAR, gamestate.HELPED, 1)
