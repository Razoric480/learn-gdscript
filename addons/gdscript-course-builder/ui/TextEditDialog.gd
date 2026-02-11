@tool
extends Window

signal confirmed

enum ContentType { TEXT, CODE }

var text := "":
	get = get_text, set = set_text
var content_type: int = ContentType.TEXT:
	set = set_content_type

@export var _text_value: TextEdit
@export var _confirm_button: Button
@export var _cancel_button: Button


func _ready() -> void:
	_text_value.text = text
	_update_editor_properties()

	_text_value.text_changed.connect(_on_text_changed)
	_confirm_button.pressed.connect(_confirm)
	_cancel_button.pressed.connect(_on_cancel_pressed)

	_text_value.gui_input.connect(_gui_input)


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.control and event.pressed and event.keycode == KEY_SPACE:
		_confirm()


# Properties
func set_text(value: String) -> void:
	text = value

	if is_inside_tree():
		_text_value.text = text


func get_text() -> String:
	if is_inside_tree():
		return _text_value.text

	return text


func set_content_type(value: int) -> void:
	content_type = value
	_update_editor_properties()


func popup_centered(size := Vector2i.ZERO) -> void:
	super.popup_centered(size)
	_text_value.grab_focus()


func set_line_column(line: int, column: int) -> void:
	_text_value.set_caret_line(line)
	_text_value.set_caret_column(column)


func get_line() -> int:
	return _text_value.get_caret_line()


func get_column() -> int:
	return _text_value.get_caret_column()


# Helpers
func _update_editor_properties() -> void:
	if not is_inside_tree():
		return

	if content_type == ContentType.CODE:
		#TODO: _text_value.show_line_numbers = true
		_text_value.draw_tabs = true
		_text_value.draw_spaces = true
		_text_value.add_theme_font_override("font", get_theme_font("source", "EditorFonts"))
	else:
		#TODO: _text_value.show_line_numbers = false
		_text_value.draw_tabs = false
		_text_value.draw_spaces = false
		_text_value.add_theme_font_override("font", get_theme_font("font", "TextEdit"))


# Handlers
func _on_text_changed() -> void:
	text = _text_value.text


func _confirm() -> void:
	confirmed.emit()
	hide()


func _on_cancel_pressed() -> void:
	text = ""
	_text_value.text = ""
	hide()
