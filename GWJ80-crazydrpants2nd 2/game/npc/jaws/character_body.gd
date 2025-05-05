extends interactable

func extendable_interaction(playermodel : Node3D, _player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.JAWS):
		Globals.quest_started(Globals.npc_names.JAWS)
	if Globals.current_time < can_interact and !frozen_in_time:
		Dialogic.start("jaws_stop_that")

func extendable_freezing(playermodel : Node3D, _player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.ROMULUS):
		Globals.quest_started(Globals.npc_names.ROMULUS)
	if Globals.current_time < freezable and !frozen_in_time:
		Dialogic.start("jaws_stop_that")
