extends NPC


func finish_quest(quest_name : Globals.npc_names, help_or_sabotage : NPC.gamestate) -> void:
	if quest_name == Globals.npc_names.ALBERT:
		logic_variables["quest_finished"] = 100
		current_gamestate = help_or_sabotage

func handle_dialogue_start(_player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.ALBERT):
		Globals.quest_started(Globals.npc_names.ALBERT)

	if Globals.current_time > 590 and Globals.quest_status.has(Globals.npc_names.OLLIE):
		if Globals.quest_status[Globals.npc_names.OLLIE] >= 100:
			start_dialogue("albert_helped_ollie")
			return
	
	if Globals.current_time < 120:
		start_dialogue("albert_waiting_experiment")
		return

	if Globals.current_time > 120 and Globals.current_time < 240:
		if _player_controller.grabbing:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("albert_delivered_cheese")
				Globals.quest_progress(Globals.npc_names.ALBERT)
				logic_variables["cheese_delivered"] = 100
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return

		start_dialogue("albert_waiting_cheese")
		return

	if Globals.current_time > 240.0:
		if _player_controller.grabbing:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("albert_delivered_cheese_late")
				return
		if !logic_variables["cheese_delivered"]:
			start_dialogue("albert_failed_experiment")
			return

	if Globals.current_time > 300.0 and Globals.current_time < 420.0:
		if logic_variables["cheese_delivered"]:
			start_dialogue("albert_room_meeting")
			Globals.quest_progress(Globals.npc_names.ALBERT)
			logic_variables["room_meeting_occurred"] = 100
			Globals.quest_progress(Globals.npc_names.ALBERT)
			return
	
	if Globals.current_time > 420.0:
		if logic_variables["room_meeting_occurred"]:
			start_dialogue("albert_waiting_for_quest")
			return
		else:
			start_dialogue("albert_was_late_to_meeting")
			return
