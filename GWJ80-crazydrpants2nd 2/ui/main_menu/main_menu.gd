extends UiPage

# TODO: Add a title and/or background art to main_menu.tscn

func _ready() -> void:
	call_deferred("_connect_buttons")
	if OS.get_name() == "Web":
		%Exit.hide()


func _connect_buttons() -> void:
	if ui:
		%Continue.pressed.connect(load_and_start)
		%NewGame.pressed.connect(_start_game)
		%HowToPlay.pressed.connect(ui.go_to.bind("HowToPlay"))
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Controls.pressed.connect(ui.go_to.bind("Controls"))
		%Credits.pressed.connect(ui.go_to.bind("Credits"))
		%Exit.pressed.connect(get_tree().call_deferred.bind("quit"))


func load_and_start() -> void:
	Globals.load_game()
	_start_game()


func _start_game() -> void:
	get_tree().paused = true
	LoadingScreen.start_load()
	await LoadingScreen.finished_entering
	get_tree().change_scene_to_file("res://game/scenes/Bigger building made with csg boxeszip/new bigger Building .tscn")
