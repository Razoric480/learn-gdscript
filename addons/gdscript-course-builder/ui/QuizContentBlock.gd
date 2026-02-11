@tool
extends MarginContainer

signal block_removed
signal quiz_resource_changed(previous_quiz, new_quiz)

# Matches the quiz type options indices the user can select using the quiz
# type OptionButton.
enum { QUIZ_TYPE_MULTIPLE_CHOICE, QUIZ_TYPE_SINGLE_CHOICE, QUIZ_TYPE_TEXT_INPUT }

enum ConfirmMode { REMOVE_BLOCK, CHANGE_QUIZ_TYPE }

const QuizChoiceListScene := preload("QuizChoiceList.tscn")
const QuizInputFieldScene := preload("QuizInputField.tscn")
const TextEditDialog := preload("res://addons/gdscript-course-builder/ui/TextEditDialog.gd")

# Edited quiz resource. Can change between a QuizChoice or a QuizInputField.
var _quiz: Quiz
var _list_index := -1
var _confirm_dialog_mode := -1
# When the user confirms changing the quiz type, set quiz type to this type option.
var _change_quiz_type_target := -1
var _drag_preview_style: StyleBox

@export var _background_panel: PanelContainer
@export var _header_bar: Control
@export var _drag_icon: TextureRect
@export var _drop_target: Control

@export var _title_label: Label
@export var _remove_button: Button

@export var _question_line_edit: LineEdit
@export var _quiz_type_options: OptionButton

@export var _body_text_edit: TextEdit
@export var _body_expand_button: Button
@export var _body_info_label: Label

@export var _explanation_text_edit: TextEdit
@export var _explanation_expand_button: Button
@export var _explanation_info_label: Label

@export var _answers_container: PanelContainer

@export var _text_edit_dialog: TextEditDialog
# Poup dialog used to confirm deleting items.
@export var _confirm_dialog: ConfirmationDialog


func _ready() -> void:
	_drag_icon.set_drag_forwarding(get_drag_preview, Callable(), Callable())

	_text_edit_dialog.size = _text_edit_dialog.min_size

	_remove_button.pressed.connect(_on_remove_block_requested)

	_body_text_edit.text_changed.connect(_on_body_text_edit_text_changed)
	_body_expand_button.pressed.connect(_open_text_edit_dialog.bind(_body_text_edit))

	_explanation_text_edit.text_changed.connect(_on_explanation_text_edit_text_changed)
	_explanation_expand_button.pressed.connect(
		_open_text_edit_dialog.bind(_explanation_text_edit),
	)

	_body_text_edit.gui_input.connect(_text_edit_gui_input.bind(_body_text_edit))
	_explanation_text_edit.gui_input.connect(
		_text_edit_gui_input.bind(_explanation_text_edit),
	)

	_question_line_edit.text_changed.connect(_on_question_line_edit_text_changed)

	_confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	_confirm_dialog.get_cancel_button().pressed.connect(_on_confirm_dialog_cancelled)

	_quiz_type_options.item_selected.connect(_on_quiz_type_options_item_selected)

	# Update theme items
	var panel_style = get_theme_stylebox("panel", "Panel").duplicate()
	if panel_style is StyleBoxFlat:
		panel_style.bg_color = get_theme_color("base_color", "Editor")
		panel_style.border_color = get_theme_color("prop_section", "Editor").lerp(
			get_theme_color("accent_color", "Editor"),
			0.1,
		)
		panel_style.border_width_bottom = 2
		panel_style.border_width_top = (
			_header_bar.size.y
			+ panel_style.get_margin(SIDE_TOP) * 2
		)
		panel_style.content_margin_left = 10
		panel_style.content_margin_right = 10
		panel_style.content_margin_bottom = 12
		panel_style.corner_detail = 4
		panel_style.set_corner_radius_all(2)
	_background_panel.add_theme_stylebox_override("panel", panel_style)

	_drag_preview_style = get_theme_stylebox("panel", "Panel").duplicate()
	if _drag_preview_style is StyleBoxFlat:
		_drag_preview_style.bg_color = get_theme_color("prop_section", "Editor").lerp(
			get_theme_color("accent_color", "Editor"),
			0.3,
		)
		_drag_preview_style.corner_detail = 4
		_drag_preview_style.set_corner_radius_all(2)

	_drag_icon.texture = get_theme_icon("Sort", "EditorIcons")
	_remove_button.icon = get_theme_icon("Remove", "EditorIcons")
	_body_expand_button.icon = get_theme_icon("DistractionFree", "EditorIcons")
	_explanation_expand_button.icon = _body_expand_button.icon


func get_drag_target_rect() -> Rect2:
	var target_rect = _drag_icon.get_global_rect()
	target_rect.position -= global_position
	return target_rect


func get_drag_preview() -> Control:
	var drag_preview := Label.new()
	drag_preview.text = "Lesson step #%d" % [_list_index + 1]
	drag_preview.add_theme_stylebox_override("normal", _drag_preview_style)
	return drag_preview


func enable_drop_target() -> void:
	_drop_target.visible = true


func disable_drop_target() -> void:
	_drop_target.visible = false


func set_list_index(index: int) -> void:
	_list_index = index
	_title_label.text = "%d." % [_list_index + 1]


# Set by the LessonDetails resource when loading a course.
#
# Updates the interface based on the passed quiz resource.
func setup(quiz_block: Quiz) -> void:
	_quiz = quiz_block

	_question_line_edit.text = _quiz.question

	_body_text_edit.text = _quiz.content_bbcode
	_body_info_label.visible = _quiz.content_bbcode.is_empty()

	_explanation_text_edit.text = _quiz.explanation_bbcode
	_explanation_info_label.visible = _quiz.explanation_bbcode.is_empty()

	if _quiz is QuizInputField:
		_quiz_type_options.selected = 2
	elif _quiz is QuizChoice:
		_quiz_type_options.selected = 0 if _quiz.is_multiple_choice else 1
	else:
		printerr("Trying to load unsupported quiz type: %s" % [_quiz.get_class()])

	_rebuild_answers()


func search(search_text: String, from_line := 0, from_column := 0) -> Vector2i:
	var result := Vector2i()
	for text_edit in [_body_text_edit, _explanation_text_edit]:
		result = text_edit.search(search_text, TextEdit.SEARCH_MATCH_CASE, from_line, from_column)
		if not result == Vector2i(-1, -1):
			var line := result.x
			var column := result.y
			text_edit.grab_focus()
			text_edit.select(line, column, line, column + search_text.length())
			break
	return result


func _rebuild_answers() -> void:
	for child in _answers_container.get_children():
		child.queue_free()

	var scene = QuizChoiceListScene if _quiz is QuizChoice else QuizInputFieldScene
	var instance = scene.instantiate()
	_answers_container.add_child(instance)
	instance.setup(_quiz)


# Helpers
func _show_confirm(message: String, title: String = "Confirm") -> void:
	_confirm_dialog.window_title = title
	_confirm_dialog.dialog_text = message
	_confirm_dialog.popup_centered(_confirm_dialog.custom_minimum_size)


# Handlers
func _on_confirm_dialog_confirmed() -> void:
	match _confirm_dialog_mode:
		ConfirmMode.REMOVE_BLOCK:
			block_removed.emit()
		ConfirmMode.CHANGE_QUIZ_TYPE:
			_change_quiz_type(_change_quiz_type_target)

	_confirm_dialog_mode = -1


func _on_confirm_dialog_cancelled() -> void:
	if _confirm_dialog_mode == ConfirmMode.CHANGE_QUIZ_TYPE:
		if _quiz is QuizInputField:
			_quiz_type_options.selected = QUIZ_TYPE_TEXT_INPUT
		elif _quiz is QuizChoice:
			_quiz_type_options.selected = (
				QUIZ_TYPE_MULTIPLE_CHOICE
				if _quiz.is_multiple_choice
				else QUIZ_TYPE_SINGLE_CHOICE
			)
		else:
			printerr("Trying to load unsupported quiz type: %s" % [_quiz.get_class()])
		_change_quiz_type_target = -1

	_confirm_dialog_mode = -1


func _on_remove_block_requested() -> void:
	_confirm_dialog_mode = ConfirmMode.REMOVE_BLOCK
	_show_confirm("Are you sure you want to remove this block?")


func _on_question_line_edit_text_changed(new_text: String) -> void:
	_quiz.question = new_text
	_quiz.emit_changed()


func _on_body_text_edit_text_changed() -> void:
	_body_info_label.visible = _body_text_edit.text.is_empty()
	_quiz.content_bbcode = _body_text_edit.text
	_quiz.emit_changed()


func _on_explanation_text_edit_text_changed() -> void:
	_explanation_info_label.visible = _explanation_text_edit.text.is_empty()
	_quiz.explanation_bbcode = _explanation_text_edit.text
	_quiz.emit_changed()


func _on_quiz_type_options_item_selected(index: int) -> void:
	_change_quiz_type_target = index
	_confirm_dialog_mode = ConfirmMode.CHANGE_QUIZ_TYPE
	_show_confirm("Are you sure you want to change the quiz type? You may lose all answer data.")


func _change_quiz_type(target := -1) -> void:
	if target in [QUIZ_TYPE_MULTIPLE_CHOICE, QUIZ_TYPE_SINGLE_CHOICE]:
		if _quiz is QuizChoice:
			_quiz.set_is_multiple_choice(target == QUIZ_TYPE_MULTIPLE_CHOICE)
		else:
			_create_new_quiz_resource(QuizChoice, _quiz)
	elif target == QUIZ_TYPE_TEXT_INPUT:
		_create_new_quiz_resource(QuizInputField, _quiz)
	else:
		printerr("Selected unsupported quiz type: %s" % [target])


func _create_new_quiz_resource(new_type, from: Quiz) -> void:
	var previous_quiz = _quiz
	_quiz = new_type.new()
	_quiz.content_bbcode = from.content_bbcode
	_quiz.question = from.question
	_quiz.hint = from.hint
	_quiz.explanation_bbcode = from.explanation_bbcode
	quiz_resource_changed.emit(previous_quiz, _quiz)
	_rebuild_answers()


# Both TextEdit nodes in the scene forward their inputs to this function to
# handle keyboard shortcuts.
func _text_edit_gui_input(event: InputEvent, source: TextEdit) -> void:
	if not event is InputEventKey:
		return
	if event.control and event.pressed and event.keycode == KEY_SPACE:
		_open_text_edit_dialog(source)


func _open_text_edit_dialog(source: TextEdit) -> void:
	if _text_edit_dialog.confirmed.is_connected(_transfer_text_edit_dialog_text):
		_text_edit_dialog.confirmed.disconnect(_transfer_text_edit_dialog_text)

	_text_edit_dialog.popup_centered()
	_text_edit_dialog.text = source.text
	_text_edit_dialog.set_line_column(source.get_caret_line(), source.get_caret_column())
	_text_edit_dialog.popup_centered()
	_text_edit_dialog.confirmed.connect(
		_transfer_text_edit_dialog_text.bind(source),
		CONNECT_ONE_SHOT,
	)


func _transfer_text_edit_dialog_text(target: TextEdit) -> void:
	target.set_text(_text_edit_dialog.text)
	target.text_changed.emit()
	_quiz.emit_changed()
	target.set_caret_line(_text_edit_dialog.get_line())
	target.set_caret_column(_text_edit_dialog.get_column())
	target.grab_focus()
