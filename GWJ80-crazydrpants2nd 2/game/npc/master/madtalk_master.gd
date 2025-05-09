extends Sprite3D
class_name madtalk_master

const SAVE_GAME_PATH : String = "user://"
@export var popup_timer : Timer
@export var madtalk_manager : madtalk_runtime
@export var madtalk_logic : BTPlayer
@onready var sub_viewport: SubViewport = $SubViewport
var logic_variables : Dictionary

func _ready() -> void:
	texture = sub_viewport.get_texture()
	Globals.saved.connect(save)
	Globals.loaded.connect(load_game)
	popup_timer.timeout.connect(advance)
	hide()

func start_popup() -> void:
	if visible:
		print_debug("is during dialogue")
		return
	madtalk_logic.update(.01)

func start_dialogue(sheet_id) -> void:
	show()
	madtalk_manager.start_dialog(sheet_id)
	popup_timer.start(Globals.popup_duration)

func abort_dialogue() -> void:
	if madtalk_manager.dialog_messagebox_active:
		madtalk_manager.dialog_abort()

func advance() -> void:
	if MadTalkGlobals.is_during_dialog:
		madtalk_manager.dialog_acknowledge()
	if MadTalkGlobals.is_during_dialog:
		popup_timer.start(Globals.popup_duration)
		return
	hide()

func save() -> void:
	var save_path = str(SAVE_GAME_PATH, get_parent().name,"madtalk.tres")
	var save_resource : madtalk_save = madtalk_save.new()
	save_resource.logic_variables = logic_variables


func load_game() -> void:
	var save_path = str(SAVE_GAME_PATH, get_parent().name,"madtalk.tres")
	if !ResourceLoader.exists(save_path):
		print_debug(get_parent().name,"madtalk.tres", "  tried to load")
		return
	
	var saved_resource : madtalk_save = load(save_path) as madtalk_save
	logic_variables = saved_resource.logic_variables
