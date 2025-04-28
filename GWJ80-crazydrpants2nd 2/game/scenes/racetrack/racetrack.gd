extends Node3D


func _ready() -> void:
	LoadingScreen.start_animation()
	await LoadingScreen.finished_loading
	Ui.get_node("PauseMenu").pausable = true
	get_tree().paused = false
	await get_tree().process_frame
	print_debug("loaded")
