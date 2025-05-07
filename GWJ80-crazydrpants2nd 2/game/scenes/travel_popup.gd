extends Node3D

@export var area_number : int = 0
@export var new_scene : String = "uid://dgmox4dyoefyf"
@export var can_interact : float = 0.0
@onready var pop_up: Node3D = $PopUp
@onready var player_spawn_position: MeshInstance3D = $PlayerSpawnPosition

func _ready() -> void:
	Globals.loaded.connect(reposition_player)
	player_spawn_position.hide()

func interact(playermodel : Node3D, _player_controller : player_controller) -> void:
	Globals.area_player_spawn = area_number
	Globals.travelling = true
	Globals.change_scene(new_scene)

func display_prompt() -> void:
	if pop_up:
		if pop_up.visible:
			return
		pop_up.pop_up_show()

func turn_off_prompt() -> void:
	if pop_up:
		pop_up.turn_off_prompt()

func reposition_player():
	if Globals.travelling:
		if Globals.area_player_spawn == area_number:
			var player : CharacterBody3D = %Player
			var player_camera : player_controller = player.get_node("camera_pivot")
			player.global_position = player_spawn_position.global_position
			player.get_node("playermodel").global_basis = player_spawn_position.global_basis
			player_camera.global_position = player.global_position + player_camera.offset
			await get_tree().create_timer(0.15).timeout
			Globals.travelling = false
