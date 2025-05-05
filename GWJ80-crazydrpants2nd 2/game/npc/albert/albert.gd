extends NPC


func finish_quest(quest_name : Globals.npc_names, help_or_sabotage : NPC.gamestate) -> void:
	if quest_name == Globals.npc_names.ALBERT:
		logic_variables["quest_finished"] = 100
		current_gamestate = help_or_sabotage

func handle_dialogue_start(_player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.ALBERT):
		Globals.quest_started(Globals.npc_names.ALBERT)
