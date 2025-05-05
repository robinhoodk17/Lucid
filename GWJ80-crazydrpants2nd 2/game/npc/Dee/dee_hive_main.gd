extends NPC

@export var timer_for_present : Timer
@export var time_of_present : float = 430.0

func extendable_ready() -> void:
	logic_variables["gave_present"] = 0
	timer_for_present.timeout.connect(fix_decision)
	timer_for_present.start(time_of_present)
	
func extendable_load():
	if Globals.current_time < time_of_present:
		timer_for_present.start(time_of_present - Globals.current_time)


func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.DEE):
		Globals.quest_started(Globals.npc_names.DEE)
		
	if Globals.quest_status[Globals.npc_names.BARRY] and logic_variables.has("convinced_barry_quest"):
		if logic_variables["convinced_barry_quest"] < 100:
			start_dialogue("dee_barry_quest")
			return

	if Globals.current_time < 300.0:
		if Globals.quest_status[Globals.npc_names.DEE] >= 100:
			start_dialogue("butterfly_council")
			return
		match current_gamestate:
			gamestate.NORMAL:
				start_dialogue("dee_skates_or_briefcase")
				return
			gamestate.HELPED:
				start_dialogue("dee_skates")
				return
			gamestate.SABOTAGED:
				start_dialogue("dee_briefcase")
				return

	if Globals.current_time > 420 and Globals.current_time < 430:
		start_dialogue("dee_already_got_present")
		return
	
	if Globals.current_time > 430:
		match current_gamestate:
			gamestate.NORMAL:
				start_dialogue("dee_undecisive")
				return
			gamestate.HELPED:
				start_dialogue("dee_good_present")
				return
			gamestate.SABOTAGED:
				start_dialogue("dee_bad_present")
				return

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "dee_union":
		logic_variables["convinced_barry_quest"] = 100
		Globals.quest_progress(Globals.npc_names.BARRY)
	
	if signal_argument == "dee_briefcase":
		current_gamestate = gamestate.SABOTAGED
	
	if signal_argument == "dee_skates":
		current_gamestate = gamestate.HELPED

func fix_decision() -> void:
	if !Globals.quest_status[Globals.npc_names.DEE] and current_gamestate != gamestate.NORMAL:
		if current_gamestate == gamestate.HELPED:
			Globals.quest_finished(Globals.npc_names.DEE, current_gamestate, 1)
		if current_gamestate == gamestate.SABOTAGED:
			Globals.quest_finished(Globals.npc_names.DEE, current_gamestate, -1)

func extendable_restart() -> void:
	logic_variables["gave_present"] = 0
	timer_for_present.stop()
	timer_for_present.start(time_of_present)
