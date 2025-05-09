extends Node3D
class_name NPC

enum states{IDLE, WALKING, TALKING}
enum gamestate{NORMAL, SABOTAGED, HELPED}
enum moods{HAPPY, SAD, AFRAID, NONE}
const SAVE_GAME_PATH : String = "user://"
@export_subgroup("need_setup")
@export var dialogic : BTPlayer
@export var madtalk_logic : BTPlayer
@export var route_manager : AnimationPlayer

@export_subgroup("Dialogue and routes")
@export var can_interact : float = 0.0
##the keys are when the event happens, and the values are eventRoute resources with
##the event's data, i.e. the gamestates {NORMAL, SABOTAGED, HELPED} where the NPC
##can move with this route and the route's name
@export var moving_times : Dictionary[float, eventRoute]
##a dictionary containing where the item should be at certain timepoints
@export var places : Dictionary[float, Marker3D]

@export_subgroup("Nodes")
@export var animation_player : AnimationPlayer
@export var timer : Timer
@export var madtalk_master_node : madtalk_master
@onready var pop_up: Node3D = $PopUp
@onready var route_logic: BTPlayer = $RouteLogic
var route_logic_result : bool = false
var moving_towards : Marker3D = null
var current_state : states = states.IDLE
var current_gamestate : gamestate = gamestate.NORMAL
var current_event : float = 0.0
var original_position : Vector3
var original_rotation : Basis
var player_control : player_controller
var logic_variables : Dictionary
var random_talks : int = 0
var quest_completed : bool = false

func _ready() -> void:
	route_logic.behavior_tree_finished.connect(route_logic_func)
	Globals.saved.connect(save)
	Globals.loaded.connect(load_game)
	Dialogic.timeline_ended.connect(unpause)
	Dialogic.signal_event.connect(handle_dialogue_end)
	madtalk_master_node.madtalk_logic = madtalk_logic
	original_position = global_position
	original_rotation = global_basis
	timer.timeout.connect(start_walking)
	var expected_time : float = 6000
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
	if animation_player.has_animation("Idle"):
		animation_player.play("Idle")
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
			expected_time = i
			#print_debug(current_event, name)
	timer.start(current_event)
	Globals.restart.connect(restart)
	extendable_ready()
	Globals.on_quest_end.connect(finish_quest)


func route_logic_func(status : int) -> bool:
	match status:
		2:
			return false
		3: 
			print_debug("ran a route logic", name)
			return true
	return false


func back_to_idle() -> void:
	current_state = states.IDLE
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
	if animation_player.has_animation("Idle"):
		animation_player.play("Idle")


func play(animation_name : String) -> void:
	animation_player.play(animation_name)


func start_walking() -> void:
	if current_event <= 0.0:
		return
	var acceptable_states : Array[gamestate] = moving_times[current_event].acceptable_states
	route_logic.behavior_tree = moving_times[current_event].dialogue_logic
	route_logic.update(.01)
	if route_logic_result:
		route_manager.play(moving_times[current_event].route)
	if current_gamestate in acceptable_states:
		current_state = states.WALKING
		route_manager.play(moving_times[current_event].route)
		#print_debug(moving_times[current_event].route)

	if animation_player.has_animation("walk"):
		animation_player.play("walk")
	if animation_player.has_animation("Walk"):
		animation_player.play("Walk")
	madtalk_master_node.abort_dialogue()
	var candidate_time : float = 6000
	for i : float in moving_times.keys():
		if i < candidate_time and i > Globals.current_time and i != current_event:
			candidate_time = i
	current_event = candidate_time
	timer.start(current_event)


func restart() -> void:
	back_to_idle()
	route_manager.stop()
	global_position = original_position
	global_basis = original_rotation
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
			expected_time = i
	timer.start(current_event)
	extendable_restart()


func display_prompt() -> void:
	if pop_up:
		if pop_up.visible:
			return
		pop_up.pop_up_show()
	if madtalk_master_node:
		madtalk_master_node.start_popup()


func turn_off_prompt() -> void:
	if pop_up:
		pop_up.turn_off_prompt()


func interact(_playermodel : Node3D, _player_controller : player_controller) -> void:
	player_control = _player_controller
	player_control.disable()
	dialogic.update(.01)
	handle_dialogue_start(_player_controller)


func start_dialogue(timeline : String, mood : moods = moods.NONE) -> void:
	if DialogicResourceUtil.get_timeline_resource(timeline) == null:
		print_debug("timeline missing:  ", timeline)
		Dialogic.start("whoops")
		return
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		Dialogic.start(timeline).process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		@warning_ignore("untyped_declaration")
		Dialogic.timeline_ended.connect(func():player_control.reenable())
		madtalk_master_node.abort_dialogue()
	#get_tree().paused = true
	#Global.playing = false
	


func unpause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.playing = true
	get_tree().paused = false
	#handle_dialogue_end()
	
func save() -> void:
	var save_path = str(SAVE_GAME_PATH, name,".tres")
	var save_resource : NPC_save = NPC_save.new()
	save_resource.can_interact = can_interact
	save_resource.random_talks = random_talks
	save_resource.current_gamestate = current_gamestate
	save_resource.logic_variables = logic_variables
	save_resource.quest_completed = quest_completed
	ResourceSaver.save(save_resource, save_path)


func load_game() -> void:
	var save_path = str(SAVE_GAME_PATH, name,".tres")
	if !ResourceLoader.exists(save_path):
		print_debug(name, "  tried to load")
		return
	
	var saved_resource : NPC_save = load(save_path) as NPC_save
	random_talks = saved_resource.random_talks
	current_gamestate = saved_resource.current_gamestate
	logic_variables = saved_resource.logic_variables
	quest_completed = saved_resource.quest_completed
	can_interact = saved_resource.can_interact
	current_event = 1000.0
	for i : float in moving_times.keys():
		if i > Globals.current_time and i < current_event:
			current_event = i
	if current_event != 0.0:
		timer.start(current_event - Globals.current_time)

	var latest_event = 0.0
	for i : float in moving_times.keys():
		if i > latest_event and i < Globals.current_time:
			latest_event = i
	if latest_event == 0.0:
		return
	var route_length : int = route_manager.get_animation(moving_times[latest_event].route).length
	##if the animation is still ongoing
	if route_length + latest_event > Globals.current_time:
		route_manager.play_section(moving_times[latest_event].route,Globals.current_time - latest_event,route_length)
	##if the animation is already finished is places the NPC where it should be
	else:
		route_manager.play_section(moving_times[latest_event].route,route_length - .05,route_length)
	extendable_load()


func report_errors():
	print_debug("time: ", Globals.current_time)
	print_debug("logic_variables: ", logic_variables)


func extendable_load():
	###Implemented by sub-classes###
	pass

func handle_dialogue_start(_player_controller : player_controller) -> void:
	###Implemented by sub-classes###
	pass


func handle_dialogue_end(signal_argument : String) -> void:
	###Implemented by sub-classes###
	pass

func extendable_ready() -> void:
	###Implemented by sub-classes###
	pass

func extendable_restart() -> void:
	###Implemented by sub-classes###
	pass

func finish_quest(quest_name : Globals.npc_names, help_or_sabotage : NPC.gamestate) -> void:
	###Implemented by sub-classes###
	pass
