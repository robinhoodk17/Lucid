extends Resource
class_name interactable_save

@export var positions_dictionary : Dictionary[int, Vector3]
@export var rotations_array : Dictionary[int, Basis]
@export var highest_index : int
@export var position : Vector3
@export var rotation : Basis
@export var already_interacted : bool
@export var freezable : float
@export var affected_by_time : bool
@export var can_interact : float
@export var frozen_in_time : bool
@export var first_encounter : bool
@export var quest_finished : bool
