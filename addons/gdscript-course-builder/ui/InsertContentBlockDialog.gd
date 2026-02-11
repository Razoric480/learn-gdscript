@tool
extends Window

signal block_selected(at_index)
signal quiz_selected(at_index)

var insert_at_index := -1

@export var _add_block_button: Button
@export var _add_quiz_button: Button
@export var _cancel_button: Button


func _ready() -> void:
	_add_block_button.pressed.connect(_on_add_block_pressed)
	_add_quiz_button.pressed.connect(_on_add_quiz_pressed)
	_cancel_button.pressed.connect(_on_cancelled)


func _on_add_block_pressed() -> void:
	block_selected.emit(insert_at_index)
	hide()


func _on_add_quiz_pressed() -> void:
	quiz_selected.emit(insert_at_index)
	hide()


func _on_cancelled() -> void:
	hide()
