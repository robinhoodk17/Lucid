extends NPC

@export var dee : NPC
@export var ice_skates : Node3D
@export var ice_skate_timer : Timer
@export var ice_skates_appear_time : float
var unlocked_technique : bool = false

func handle_dialogue_start(_player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.CEE):
		Globals.quest_started(Globals.npc_names.CEE)
		return

	if Globals.current_time > 180 and Globals.current_time < 300.0:
		start_dialogue("cee_talks_to_dee")
		return


	
	if Globals.current_time < 60 and unlocked_technique:
		start_dialogue("cee_looks_at_stain_variant")
		Globals.quest_finished(Globals.npc_names.CEE, gamestate.HELPED, 1)
		return

	if current_gamestate == gamestate.HELPED:
		if Globals.current_time < 180:
			start_dialogue("cee_in_clean_room")
			return

	if Globals.current_time > 60 and Globals.current_time < 120 and current_gamestate == gamestate.NORMAL:
		start_dialogue("cee_looking_for_help")

	if current_gamestate == gamestate.NORMAL:
		if Globals.current_time > 300.0 and Globals.current_time < 480.0:
			start_dialogue("cee_talks_to_vinnie")
			unlocked_technique = true
			return
	
	if Globals.current_time > 480.0:
		if dee.current_gamestate == gamestate.NORMAL:
			start_dialogue("cee_chils_in_cafeteria")
			return
		if dee.current_gamestate == gamestate.HELPED:
			start_dialogue("cee_in_love_with_dee")
			return
		if dee.current_gamestate == gamestate.SABOTAGED:
			start_dialogue("cee_was_right_about_dee")
			return

func restart() -> void:
	ice_skate_timer.start(ice_skates_appear_time)
	ice_skates.hide()
	animation_player.stop()
	route_manager.stop()
	route_manager.stop()
	global_position = original_position
	global_basis = original_rotation
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "cee_union":
		logic_variables["convinced_barry_quest"] = 100
		Globals.quest_progress(Globals.npc_names.BARRY)
