extends CharacterBody3D

@onready var trail_timer: Timer = $TrailTimer
@onready var dash_trail: Node3D = $playermodel/DashTrail
@export var dash_duration : float = 0.5
@onready var playermodel: Node3D = $playermodel

func _ready() -> void:
	Globals.player_spawn_position = global_position
	Globals.player_spawn_rotation = global_basis
	trail_timer.timeout.connect(finish_dash)

func spin() -> void:
		dash_trail.show()
		trail_timer.start(dash_duration)
		doFullCircle()

func doFullCircle(axis : String = "z"):
	randomize()
	var leftorRight : int = -1
	if randi_range(0,1):
		leftorRight = 1
	var target_rotation = playermodel.rotation
	if axis == "z":
		target_rotation.z += PI*2 * leftorRight
	var rotate_tween = get_tree().create_tween()
	rotate_tween.tween_property(playermodel, "rotation", target_rotation, dash_duration).set_trans(Tween.TRANS_LINEAR)

func finish_dash():
	dash_trail.hide()
