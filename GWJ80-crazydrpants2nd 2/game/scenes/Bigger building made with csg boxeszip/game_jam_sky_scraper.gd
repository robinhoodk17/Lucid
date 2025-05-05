extends Node3D

@export var default_mapping_context: GUIDEMappingContext
#@onready var ui: CanvasLayer = $UI
@onready var camera_pivot: player_controller = $NPCs/Player/camera_pivot

func _ready() -> void:
	call_deferred("late_ready")


func  late_ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GUIDE.enable_mapping_context(default_mapping_context)
	Ui.get_node("PauseMenu").pausable = true
	Ui.go_to("Game")
	if Globals.newload:
		for i in Globals.run_number + 1:
			match i-1:
				1:
					var new_player : CharacterBody3D = Globals.PLAYER.instantiate()
					get_tree().root.add_child(new_player)
					new_player.global_position = Globals.player_spawn_position
					new_player.global_basis = Globals.player_spawn_rotation
					var new_controller : prewritten = Globals.PREWRITTEN_CONTROLLER.instantiate()
					new_controller.frame_info = Globals.first_run
					new_player.add_child(new_controller)
					new_controller.physics_tick = Globals.physics_tick * Globals.item_refresh_rate
				2:
					var new_player : CharacterBody3D = Globals.PLAYER.instantiate()
					get_tree().root.add_child(new_player)
					new_player.global_position = Globals.player_spawn_position
					new_player.global_basis = Globals.player_spawn_rotation
					var new_controller : prewritten = Globals.PREWRITTEN_CONTROLLER.instantiate()
					new_controller.frame_info = Globals.second_run
					new_player.add_child(new_controller)
					new_controller.physics_tick = Globals.physics_tick * Globals.item_refresh_rate
		Globals.loaded.emit()
		Globals.newload = false
	LoadingScreen.start_animation()
	await LoadingScreen.finished_loading
	get_tree().paused = false
	await get_tree().process_frame
	if Globals.first_time_playing:
		Globals.first_time_playing = false
		camera_pivot.disable()
		Dialogic.start("opening_scrawl")
		Dialogic.timeline_ended.connect(func():camera_pivot.reenable())
	$Music/ButterflyLoop.play()
	$Music/ClockSpawn.play()
	Ui.get_node("Game/Label").start_counting = true
