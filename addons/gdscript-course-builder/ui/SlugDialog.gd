@tool
extends Window

signal confirmed

var slug_text := "": get = get_text, set = set_text

@onready var _slug_label := $Margin/Layout/SlugText/Label as Label
@onready var _slug_value := $Margin/Layout/SlugText/LineEdit as LineEdit
@onready var _confirm_button := $Margin/Layout/Buttons/ConfirmButton as Button
@onready var _cancel_button := $Margin/Layout/Buttons/CancelButton as Button


func _ready() -> void:
	_update_theme()
	_slug_value.text = slug_text

	_slug_value.connect("text_changed", Callable(self, "_on_text_changed"))
	_confirm_button.connect("pressed", Callable(self, "_on_confirm_pressed"))
	_cancel_button.connect("pressed", Callable(self, "_on_cancel_pressed"))


func _update_theme() -> void:
	if not is_inside_tree():
		return

	_slug_label.add_theme_color_override("font_color", get_theme_color("disabled_font_color", "Editor"))


# Properties
func set_text(value: String) -> void:
	slug_text = value

	if is_inside_tree():
		_slug_value.text = slug_text


func get_text() -> String:
	if is_inside_tree():
		return _slug_value.text

	return slug_text


# Handlers
func _on_text_changed(value: String) -> void:
	slug_text = value


func _on_confirm_pressed() -> void:
	emit_signal("confirmed")
	hide()


func _on_cancel_pressed() -> void:
	slug_text = ""
	_slug_value.text = ""
	hide()
