extends CharacterBody3D
class_name interactable
enum item_type{CHEESE, LETTER, PIGGY, FILES, BADGE, ROLLERBLADES, MAIL}
##a dictionary containing where the item should be at certain timepoints
@export var places : Dictionary[float, Marker3D]
@export var already_interacted : bool = false
@export var freezable : bool = false
@export var affected_by_time : bool = true
@export var can_interact : bool = true
@export var type : item_type = item_type.CHEESE
@onready var pop_up: Node3D = $PopUp
@onready var quest_finished : bool = false

const SAVE_GAME_PATH : String = "user://"
var frozen_in_time : bool = false
var first_encounter : bool = false
var player_model : Node3D
var grabbed : bool = false
var positions_dictionary : Dictionary[int, Vector3]
var rotations_dictionary : Dictionary[int, Basis]
var current_refresh : int = 0
var refresh_turn : int = 0
var refresh_counter : int = 0
var highest_index : int = 0

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
		

func _physics_process(delta: float) -> void:
	#if name == "RollerBlades":
		#print_debug("before ", !positions_dictionary.has(Globals.physics_tick), "  ", current_refresh, "  tick: ", Globals.physics_tick)
	refresh_counter = (refresh_counter + 1) % Globals.item_refresh_rate
	current_refresh = (refresh_counter + refresh_turn) % Globals.item_refresh_rate

	if !grabbed and (Globals.physics_tick > highest_index - 1 or frozen_in_time):
		velocity += get_gravity() * delta * 2.0
		move_and_slide()

	if current_refresh == 0 and !frozen_in_time:
		if positions_dictionary.has(Globals.physics_tick):
			global_position = positions_dictionary[Globals.physics_tick]
			global_basis = rotations_dictionary[Globals.physics_tick]
		else:
			if Globals.physics_tick > highest_index:
				highest_index = Globals.physics_tick
			positions_dictionary[Globals.physics_tick] = global_position
			rotations_dictionary[Globals.physics_tick] = global_basis


	if grabbed:
		global_position = player_model.global_position - player_model.basis.z
		velocity = Vector3.ZERO


func freeze_in_time() -> void:
	frozen_in_time = true

	Globals.lost_item.emit()
	first_encounter = false

	positions_dictionary.clear()
	rotations_dictionary.clear()
	Dialogic.start("freeze_in_time").process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	@warning_ignore("untyped_declaration")
	Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
	get_tree().paused = true



func interact(playermodel : Node3D, _player_controller : player_controller) -> void:
	grab(playermodel, _player_controller)
	
func grab(_player_model : Node3D, _player_controller : player_controller) -> void:
	highest_index = Globals.physics_tick
	for i in positions_dictionary.keys():
		if i > Globals.physics_tick:
			positions_dictionary.erase(i)
			rotations_dictionary.erase(i)
			
	if quest_finished:
		#Dialogic.start("butterfly_council").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("butterfly_council")
		return
		#Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		#@warning_ignore("untyped_declaration")
		#Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
		#get_tree().paused = true
		
	if _player_controller.grabbing != null:
		_player_controller.grabbing.drop()
	_player_controller.grabbing = self
	collision_layer = 0
	collision_mask = 0
	player_model = _player_model
	grabbed = true
	Globals.item_grabbed.emit()


func drop() -> void:
	global_position = global_position + Vector3.UP
	collision_layer = 4
	collision_mask = 1
	grabbed = false
	Globals.item_dropped.emit()


func display_prompt() -> void:
	if first_encounter and freezable:
		Globals.found_item.emit()
	if pop_up:
		if pop_up.visible:
			return
		pop_up.pop_up_show()


func turn_off_prompt() -> void:
	first_encounter = false
	Globals.lost_item.emit()
	#%TimeTravelPrompt.turn_off_prompt()
	if pop_up:
		pop_up.turn_off_prompt()


func on_restart() -> void:
	drop()
	current_refresh = 0
	if frozen_in_time:
		return
	global_position = positions_dictionary[0]
	global_basis = rotations_dictionary[0]


func save() -> void:
	var save_path = str(SAVE_GAME_PATH, name,".tres")
	var save_resource : interactable_save = interactable_save.new()
	save_resource.positions_dictionary = positions_dictionary
	save_resource.rotations_array = rotations_dictionary
	save_resource.highest_index = highest_index
	save_resource.position = global_position
	save_resource.rotation = global_basis
	save_resource.already_interacted = already_interacted
	save_resource.freezable = freezable
	save_resource.affected_by_time = affected_by_time
	save_resource.can_interact = can_interact
	save_resource.frozen_in_time = frozen_in_time
	ResourceSaver.save(save_resource, save_path)
	pass


func load_game() -> void:
	var save_path = str(SAVE_GAME_PATH, name,".tres")
	if !ResourceLoader.exists(save_path):
		print_debug(name, "  tried to load")
		return
	var saved_resource : interactable_save = load(save_path) as interactable_save
	positions_dictionary.clear()
	positions_dictionary = saved_resource.positions_dictionary.duplicate()
	rotations_dictionary.clear()
	rotations_dictionary = saved_resource.rotations_array.duplicate()
	highest_index = saved_resource.highest_index
	global_position = saved_resource.position
	global_basis = saved_resource.rotation
	already_interacted = saved_resource.already_interacted
	freezable = saved_resource.freezable
	affected_by_time = saved_resource.affected_by_time
	can_interact = saved_resource.can_interact
	frozen_in_time = saved_resource.frozen_in_time
