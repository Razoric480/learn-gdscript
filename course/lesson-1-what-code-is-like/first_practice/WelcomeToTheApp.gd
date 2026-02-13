extends Node2D

@export var _animation_tree: AnimationTree

# EXPORT welcome_to_app
func _ready():
	print("Welcome!")
# /EXPORT welcome_to_app
	await get_tree().create_timer(1.0).timeout
	Events.practice_completed.emit()

func _run():
	_animation_tree.travel("saying_hi")
