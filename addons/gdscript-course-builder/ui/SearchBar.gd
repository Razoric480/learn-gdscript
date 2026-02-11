@tool
extends HBoxContainer

signal next_match_requested(text)

var is_active: bool:
	set = set_is_active
var search_text: String:
	set = set_search_text

@export var _line_edit: LineEdit
@export var _next_button: Button


func _ready() -> void:
	set_is_active(false)
	_line_edit.text_submitted.connect(set_search_text)
	_next_button.pressed.connect(_request_next_match)


func set_search_text(text: String) -> void:
	if text == search_text:
		return
	search_text = text
	if not search_text.is_empty():
		next_match_requested.emit(search_text)


func set_is_active(value: bool) -> void:
	is_active = value
	_line_edit.editable = is_active
	_next_button.disabled = not is_active


func _request_next_match() -> void:
	if search_text.is_empty():
		search_text = _line_edit.text
	if not search_text.is_empty():
		next_match_requested.emit(search_text)
