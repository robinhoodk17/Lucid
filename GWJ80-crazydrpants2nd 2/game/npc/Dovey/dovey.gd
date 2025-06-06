extends NPC

@export var romulus : NPC
var quest_finished : bool = false
var player : player_controller

func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.DOVEY):
		Globals.quest_started(Globals.npc_names.DOVEY)
	player = _player_controller
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.MAIL:
			if Globals.quest_status[Globals.npc_names.DOVEY] < 100:
				if Globals.current_time > 240.0 and Globals.current_time < 420.0:
					start_dialogue("dovey_receive_mail")
					quest_finished = true
					Globals.quest_finished(Globals.npc_names.DOVEY, gamestate.HELPED)
					current_gamestate = gamestate.HELPED
					var item : Node3D = _player_controller.grabbing
					item.quest_finished = true
					item.drop()
					_player_controller.grabbing = null
					item.global_position = Vector3(0,1000,0)
					return

				if Globals.current_time < 240.0:
					start_dialogue("dovey_not_understand_early")
					return

				if Globals.current_time > 420.0:
					start_dialogue("dovey_not_understand_late")
					return
			else:
				start_dialogue("butterfly_council")
				return
		if _player_controller.grabbing.type == interactable.item_type.PIGGY:
			if Globals.quest_status.has(Globals.npc_names.ROMULUS):
				if Globals.quest_status[Globals.npc_names.ROMULUS] < 100:
					start_dialogue("dovey_convince_piggy_bank")
					return
				else:
					start_dialogue("butterfly_council")
	else:
		if Globals.current_time > 240.0 and Globals.current_time < 420.0:
			if Globals.quest_status[Globals.npc_names.DOVEY] < 100:
					start_dialogue("dovey_looking_for_mail")
					return

		if Globals.current_time < 240.0:
			start_dialogue("dovey_chilling")
			return

		if Globals.current_time > 420.0 or (Globals.quest_status[Globals.npc_names.DOVEY] >= 100 and current_gamestate == gamestate.HELPED):
			start_dialogue("dovey_found_mail")
			return
		
func  handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "dovey_romulus_piggy":
		Globals.quest_finished(Globals.npc_names.ROMULUS,gamestate.SABOTAGED, -1)
		var item : Node3D = player.grabbing
		item.drop()
		player.grabbing = null
		item.global_position = Vector3(0,1000,0)
