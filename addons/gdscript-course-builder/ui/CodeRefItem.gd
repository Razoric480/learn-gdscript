@tool
# Single choice field for the code reference list.
#
# Displays buttons to sort and remove the field.
class_name CodeRefItem
extends MarginContainer

signal text_changed
signal index_changed
signal removed

@export var _background_panel: PanelContainer
@export var _sort_up_button: Button
@export var _sort_down_button: Button
@export var _index_label: Label
@export var _line_edit: LineEdit
@export var _remove_button: Button
@export var _confirm_dialog: ConfirmationDialog

var list_index := -1:
	set = set_list_index

@onready var _parent := get_parent() as Container


func _ready() -> void:
	_sort_up_button.pressed.connect(_change_position_in_parent.bind(-1))
	_sort_down_button.pressed.connect(_change_position_in_parent.bind(1))

	_remove_button.pressed.connect(_on_remove_requested)
	_line_edit.text_changed.connect(_on_text_changed)

	_confirm_dialog.confirmed.connect(_remove)

	_index_label.text = "%d." % [get_index()]

	# Update theme items
	var panel_style = get_theme_stylebox("panel", "Panel").duplicate()
	if panel_style is StyleBoxFlat:
		panel_style.bg_color = get_theme_color("base_color", "Editor")
		panel_style.corner_detail = 4
		panel_style.set_corner_radius_all(2)
	_background_panel.add_theme_stylebox_override("panel", panel_style)

	_sort_up_button.icon = get_theme_icon("ArrowUp", "EditorIcons")
	_sort_down_button.icon = get_theme_icon("ArrowDown", "EditorIcons")
	_remove_button.icon = get_theme_icon("Remove", "EditorIcons")


func set_text(value: String) -> void:
	if not _line_edit:
		await self.ready
	_line_edit.text = value


func get_text() -> String:
	return _line_edit.text


func set_list_index(index: int) -> void:
	_index_label.text = "%d." % [index]


func _on_remove_requested() -> void:
	_confirm_dialog.window_title = "Confirm"
	_confirm_dialog.dialog_text = "Are you sure you want to remove this choice?"
	_confirm_dialog.popup_centered(_confirm_dialog.custom_minimum_size)


func _on_text_changed(new_text: String) -> void:
	text_changed.emit()


func _change_position_in_parent(offset: int) -> void:
	var new_index := get_index() + offset
	# The parent node has a header row which occupies the index 0.
	if new_index < 1 or new_index >= _parent.get_child_count():
		return
	_parent.move_child(self, new_index)
	index_changed.emit()


func _remove() -> void:
	queue_free()
	removed.emit()
