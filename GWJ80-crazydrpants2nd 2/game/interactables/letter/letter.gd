extends interactable

func extendable_interaction(playermodel : Node3D, _player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.VINNY):
		Globals.quest_started(Globals.npc_names.VINNY)
