extends Resource
class_name eventRoute

@export var acceptable_states : Array[NPC.gamestate] = [NPC.gamestate.NORMAL]
@export var route : String = "route1"
@export var dialogue_logic : Resource = load("res://game/npc/albert/behavior_trees/routes/route1.tres")
