extends interactable

@export var experiment_timer : Timer
@export var experiment_length : float = 120

func _ready() -> void:
	Globals.saved.connect(save)
	Globals.loaded.connect(load_game)
	refresh_turn = randi() % Globals.item_refresh_rate
	first_encounter = true
	Globals.restart.connect(on_restart)
	var starting_location : int = 0
	positions_dictionary[0] = global_position
	rotations_dictionary[0] = global_basis
	for i in places.keys():
		if i < Globals.current_time and i > starting_location:
			starting_location = i
	global_position = positions_dictionary[starting_location]
	global_basis = rotations_dictionary[starting_location]


func can_interact_again() -> void:
	can_interact = true
	global_position = Vector3(0, 1000,0)


func on_restart() -> void:
	drop()
	drop()
	current_refresh = 0
	if frozen_in_time:
		return
	global_position = positions_dictionary[0]
	global_basis = rotations_dictionary[0]
	experiment_timer.start(experiment_length)
	can_interact = false
