extends Node

# What goes into globals.gd?
# If the function depends on the something in the game, it's a global.
# If it's independent, it (probably) belongs in utils.gd
## Use UI/MessageBox to display a status update message to the player
signal post_ui_message(text: String)
## Emitted by UI/Controls when a action is remapped
signal controls_changed(config: GUIDERemappingConfig)
signal saved
signal loaded
signal found_item
signal lost_item
signal restart
signal last_minute
signal on_quest_start(quest_name : String, help_or_sabotage : NPC.gamestate)
signal on_quest_end(quest_name : String, help_or_sabotage : NPC.gamestate)
signal on_quest_progress(quest_name : String)
signal item_grabbed
signal item_dropped

const PREWRITTEN_CONTROLLER : PackedScene = preload("res://game/player/player_controllers/prewritten_controller.tscn")
const PLAYER : PackedScene = preload("res://game/player/player.tscn")
const SAVE_GAME_PATH : String = "user://save.tres"
@export var quest_status : Dictionary[String, int] = {"vinny" : -1, "barry" : -1}
var time_scale : float = 1.0
var run_number : int = 1
var run_limit : int = 3
var current_time : float = 0.0
var physics_tick : int = 0
var first_run : Array[Dictionary]
var second_run : Array[Dictionary]
var player_spawn_position : Vector3
var player_spawn_rotation : Basis
var running_karma : int = 0
var naughty_quests : int = 0
var nice_quests : int = 0
#How many physics ticks pass between refreshing the position of items
var item_refresh_rate : int = 10
var sensitivity : float = 1.0

func _restart() -> void:
	save()
	run_number += 1
	if run_number > run_limit:
		get_tree().change_scene_to_file("res://game/scenes/results_page.tscn")
		return
	var new_player : CharacterBody3D = PLAYER.instantiate()
	get_tree().root.add_child(new_player)
	new_player.global_position = player_spawn_position
	new_player.global_basis = player_spawn_rotation
	var new_controller : prewritten = PREWRITTEN_CONTROLLER.instantiate()
	match run_number -1:
		1:
			new_controller.frame_info = first_run
		2:
			new_controller.frame_info = second_run
	new_player.add_child(new_controller)
	current_time = 0.0
	restart.emit()


func quest_started(quest_name : String, help_or_sabotage : NPC.gamestate = NPC.gamestate.NORMAL) -> void:
	quest_status[quest_name] = 0
	on_quest_start.emit(quest_name, help_or_sabotage)


func quest_finished(quest_name : String, help_or_sabotage : NPC.gamestate, karma : int = 0) -> void:
	quest_status[quest_name] = 100
	on_quest_end.emit(quest_name)
	running_karma += karma
	if karma > 0:
		nice_quests += karma
	if karma < 0:
		naughty_quests += -karma
	print_debug(running_karma)


func quest_progress(quest_name : String) -> void:
	quest_status[quest_name] += 1
	on_quest_progress.emit(quest_name)


func append_frame_data(frame_data : Dictionary) -> void:
	match run_number:
		1:
			first_run.append(frame_data)
		2:
			second_run.append(frame_data)
		3:
			return


func change_scene(file_name : String):
	if Ui.get_node("Game/Label") != null:
		Ui.get_node("Game/Label").start_counting = false
	Ui.get_node("PauseMenu").pausable = false
	get_tree().paused = true
	LoadingScreen.start_load()
	await LoadingScreen.finished_entering
	save()
	get_tree().change_scene_to_file(file_name)
	load_game()

func save():
	var save_resource : global_save = global_save.new()
	print_debug("before", save_resource.current_time)
	save_resource.current_time = current_time
	save_resource.first_run = first_run
	save_resource.second_run = second_run
	save_resource.quest_status = quest_status
	save_resource.run_number = run_number
	saved.emit()
	ResourceSaver.save(save_resource, SAVE_GAME_PATH)
	print_debug("after", save_resource.current_time)


func load_game():
	if !ResourceLoader.exists(SAVE_GAME_PATH):
		print_debug("tried to load")
		return
	print_debug("actually loaded")
	var saved_resource : global_save = load(SAVE_GAME_PATH) as global_save
	current_time = saved_resource.current_time
	print_debug("loaded time", current_time)
	first_run = saved_resource.first_run
	second_run = saved_resource.second_run
	quest_status = saved_resource.quest_status
	run_number = saved_resource.run_number
	loaded.emit()
