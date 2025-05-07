extends Node
class_name prewritten

var frame_info : Array[Dictionary]
var player : CharacterBody3D
var physics_tick : int = 0
@onready var playermodel : Node3D = $"../playermodel"

func _ready() -> void:
	player = $".."
	$"../playermodel/Butterfly/AnimationPlayer".play("flap")
	Globals.restart.connect(restarted)


func _physics_process(delta: float) -> void:
	var hiding = false
	if physics_tick >= frame_info.size():
		physics_tick = frame_info.size()-1
		player.hide()
		hiding = true
	player.global_position = frame_info[physics_tick]["position"]
	playermodel.global_basis = frame_info[physics_tick]["rotation"]
	var current_input : String = frame_info[physics_tick]["input"]
	#var current_talk : Dictionary = frame_info[physics_tick]["talk"]
	#print_debug(frame_info[physics_tick])
	if current_input == "dash":
		player.spin()
	if Globals.scene_name == frame_info[physics_tick]["scene"] and !hiding:
		player.show()
	else:
		player.hide()
	physics_tick += 1 * Globals.time_scale


func restarted() -> void:
	physics_tick = 0
