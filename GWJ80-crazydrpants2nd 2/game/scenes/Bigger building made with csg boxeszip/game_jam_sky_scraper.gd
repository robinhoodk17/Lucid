extends Node3D

@export var default_mapping_context: GUIDEMappingContext
@onready var ui: CanvasLayer = $UI
@onready var camera_pivot: player_controller = $NPCs/Player/camera_pivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GUIDE.enable_mapping_context(default_mapping_context)
	ui.get_node("PauseMenu").pausable = true
	LoadingScreen.start_animation()
	await LoadingScreen.finished_loading
	get_tree().paused = false
	await get_tree().process_frame
	camera_pivot.disable()
	Dialogic.start("opening_scrawl")
	Dialogic.timeline_ended.connect(func():camera_pivot.reenable())
	$Music/ButterflyLoop.play()
	$Music/ClockSpawn.play()
	$UI.go_to("Game")
	$UI/Game/Label.start_counting = true
