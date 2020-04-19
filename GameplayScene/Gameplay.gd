extends Node2D

onready var ysort_group = $YSort

# Used to add entities that need to be y-sorted, like enemies
func add_entity(entity) -> void:
    ysort_group.add_child(entity)
