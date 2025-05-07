extends interactable

@export var experiment_timer : Timer
@export var second_teleport_timer : Timer
@export var first_teleport : float = 120
@export var second_teleport : float = 540

func extendable_restart() -> void:
	if Globals.current_time < first_teleport:
		experiment_timer.start(Globals.current_time - first_teleport)
	elif Globals.current_time < second_teleport:
		second_teleport_timer.start(Globals.current_time - second_teleport)

func extendable_ready() -> void:
	experiment_timer.timeout.connect(teleport)
	second_teleport_timer.timeout.connect(teleport_2)
	if Globals.current_time < first_teleport:
		experiment_timer.start(first_teleport - Globals.current_time)
	if Globals.current_time < second_teleport:
		experiment_timer.start(second_teleport - Globals.current_time)

func teleport_2() -> void:
	if frozen_in_time:
		return
	global_position = positions_dictionary[0]
	print_debug(positions_dictionary[0])

func teleport() -> void:
	if frozen_in_time:
		return
	global_position = Vector3(0, 1000, 0)
	print_debug(positions_dictionary[0])

func extendable_interaction(playermodel : Node3D, _player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.ALBERT):
		Globals.quest_started(Globals.npc_names.ALBERT)

func extendable_freezing(playermodel : Node3D, _player_controller : player_controller) -> void:
	if !Globals.quest_status.has(Globals.npc_names.ALBERT):
		Globals.quest_started(Globals.npc_names.ALBERT)
