@tool
extends Node

# What goes into globals.gd?
# If the function depends on the something in the game, it's a global.
# If it's independent, it (probably) belongs in utils.gd
## Use UI/MessageBox to display a status update message to the player
signal post_ui_message(text: String)
## Emitted by UI/Controls when a action is remapped
signal controls_changed(config: GUIDERemappingConfig)
signal context_changed()
signal saved
signal loaded
signal found_item
signal lost_item
signal restart
signal last_minute
signal on_quest_start(quest_name : npc_names, help_or_sabotage : NPC.gamestate)
signal on_quest_end(quest_name : npc_names, help_or_sabotage : NPC.gamestate)
signal on_quest_progress(quest_name : npc_names)
signal item_grabbed
signal item_dropped

enum npc_names{CEE, DEE, MEE, ROMULUS, JAWS, DOVEY, VINNY, QUEEN_BEE, HIRO, CHESTER, ALBERT, MAMA_BEAR, OLLIE, BARRY}
var npc_names_strings : Array[String] = ["CEE", "DEE", "MEE", "ROMULUS", "JAWS", "DOVEY", "VINNY", "QUEEN_BEE", "HIRO", "CHESTER", "ALBERT", "MAMA_BEAR", "OLLIE", "BARRY"]
const PREWRITTEN_CONTROLLER : PackedScene = preload("res://game/player/player_controllers/prewritten_controller.tscn")
const PLAYER : PackedScene = preload("res://game/player/player.tscn")
const SAVE_GAME_PATH : String = "user://save.tres"
@export var context_mappings : Array[GUIDEMappingContext]
@export var change_mapping : GUIDEAction
var current_mapping : int = 0
var quest_status : Dictionary
var area_player_spawn : int = 1
var scene_name : int = 0
var travelling : bool = false
var first_time_playing : bool = true
var newload : bool = false
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
var item_refresh_rate : int = 5
var popup_duration : float = 4.0
var sensitivity : float = 1.0

func _ready() -> void:
	call_deferred("late_ready")
func late_ready() -> void:
	GUIDE.enable_mapping_context(context_mappings[current_mapping])
	change_mapping.triggered.connect(change_mapping_context)


func change_mapping_context() -> void:
	GUIDE.disable_mapping_context(context_mappings[current_mapping])
	current_mapping = (current_mapping + 1) % context_mappings.size()
	GUIDE.enable_mapping_context(context_mappings[current_mapping])
	context_changed.emit()



func _restart() -> void:
	physics_tick = 0
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
	save()
	restart.emit()


func quest_started(quest_name : npc_names) -> void:
	quest_status[quest_name] = 0
	on_quest_start.emit(quest_name)


func quest_finished(quest_name : npc_names, help_or_sabotage : NPC.gamestate, karma : int = 0) -> void:
	quest_status[quest_name] = 100
	on_quest_end.emit(quest_name)
	running_karma += karma
	if karma > 0:
		nice_quests += karma
	if karma < 0:
		naughty_quests += -karma
	print_debug(running_karma)


func quest_progress(quest_name : npc_names) -> void:
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
	load_game()
	get_tree().change_scene_to_file(file_name)


func save():
	var save_resource : global_save = global_save.new()
	save_resource.current_time = current_time
	save_resource.physics_tick = physics_tick
	save_resource.first_run = first_run
	save_resource.second_run = second_run
	save_resource.quest_status = quest_status
	save_resource.run_number = run_number
	save_resource.first_time_playing = first_time_playing
	saved.emit()
	ResourceSaver.save(save_resource, SAVE_GAME_PATH)


func load_game():
	if !ResourceLoader.exists(SAVE_GAME_PATH):
		print_debug("tried to load")
		return
	var saved_resource : global_save = load(SAVE_GAME_PATH) as global_save
	current_time = saved_resource.current_time
	print_debug("actually loaded ", current_time)
	physics_tick = saved_resource.physics_tick
	first_run = saved_resource.first_run
	second_run = saved_resource.second_run
	quest_status = saved_resource.quest_status
	run_number = saved_resource.run_number
	first_time_playing = saved_resource.first_time_playing
	newload = true
