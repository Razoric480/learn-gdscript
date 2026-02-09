class_name UIBaseQuiz
extends PanelContainer

signal quiz_passed
signal quiz_skipped

const ERROR_OUTLINE := preload("res://ui/theme/quiz_outline_error.tres")
const PASSED_OUTLINE := preload("res://ui/theme/quiz_outline_passed.tres")
const NEUTRAL_OUTLINE := preload("res://ui/theme/quiz_outline_neutral.tres")

const OUTLINE_FLASH_DURATION := 0.8
const OUTLINE_FLASH_DELAY := 0.75
const ERROR_SHAKE_TIME := 0.5
const ERROR_SHAKE_SIZE := 20
const FADE_IN_TIME := 0.3
const FADE_OUT_TIME := 0.3
const SIZE_CHANGE_TIME := 0.5

@export var test_quiz: Resource

var completed_before := false: set = set_completed_before

@onready var _outline := $Outline as PanelContainer
@onready var _question := $ClipContentBoundary/ChoiceContainer/ChoiceView/QuizHeader/Question as RichTextLabel
@onready var _explanation := $ClipContentBoundary/ResultContainer/ResultView/Explanation as RichTextLabel
@onready var _content := $ClipContentBoundary/ChoiceContainer/ChoiceView/Content as RichTextLabel
@onready var _completed_before_icon := (
	$ClipContentBoundary/ChoiceContainer/ChoiceView/QuizHeader/CompletedBeforeIcon as TextureRect
)

@onready var _choice_container := $ClipContentBoundary/ChoiceContainer as MarginContainer
@onready var _result_container := $ClipContentBoundary/ResultContainer as MarginContainer

@onready var _submit_button := $ClipContentBoundary/ChoiceContainer/ChoiceView/HBoxContainer/SubmitButton as Button
@onready var _skip_button := $ClipContentBoundary/ChoiceContainer/ChoiceView/HBoxContainer/SkipButton as Button

@onready var _result_label := $ClipContentBoundary/ResultContainer/ResultView/Label as Label
@onready var _correct_answer_label := $ClipContentBoundary/ResultContainer/ResultView/CorrectAnswer as Label

var _error_tween: Tween
var _size_tween: Tween
@onready var _help_message := $ClipContentBoundary/ChoiceContainer/ChoiceView/HelpMessage as Label

var _quiz: Quiz
var _shake_pos: float = 0
# Used for animating size changes
var _previous_rect_size := size
var _next_rect_size := Vector2.ZERO
var _percent_transformed := 0.0
var _animating_hint := false


func _ready() -> void:
	_completed_before_icon.visible = completed_before

	_submit_button.connect("pressed", Callable(self, "_test_answer"))
	_skip_button.connect("pressed", Callable(self, "_show_answer").bind(false))
	connect("item_rect_changed", Callable(self, "_on_item_rect_changed"))

	_help_message.connect("visibility_changed", Callable(self, "_on_help_message_visibility_changed"))
	_choice_container.connect("minimum_size_changed", Callable(self, "_on_choice_container_minimum_size_changed"))
	_result_container.connect("minimum_size_changed", Callable(self, "_on_result_container_minimum_size_changed"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_labels()


func setup(quiz: Quiz) -> void:
	_quiz = quiz

	if not is_inside_tree():
		await self.ready

	_question.text = "[b]" + tr(_quiz.question) + "[/b]"

	_content.visible = not _quiz.content_bbcode.is_empty()
	_content.text = TextUtils.bbcode_add_code_color(TextUtils.tr_paragraph(_quiz.content_bbcode))

	_explanation.visible = not _quiz.explanation_bbcode.is_empty()
	_explanation.text = TextUtils.bbcode_add_code_color(TextUtils.tr_paragraph(_quiz.explanation_bbcode))


func set_completed_before(value: bool) -> void:
	completed_before = value

	if is_inside_tree():
		_completed_before_icon.visible = completed_before


func _update_labels() -> void:
	if not _quiz:
		return

	_question.text = "[b]" + tr(_quiz.question) + "[/b]"

	_content.text = TextUtils.bbcode_add_code_color(TextUtils.tr_paragraph(_quiz.content_bbcode))
	_explanation.text = TextUtils.bbcode_add_code_color(TextUtils.tr_paragraph(_quiz.explanation_bbcode))


# Virtual
func _get_answers() -> Array:
	return []


func _test_answer() -> void:
	var result: Quiz.AnswerTestResult = null
	_skip_button.disabled = false
	if _quiz is QuizChoice:
		result = _quiz.test_answer(_get_answers())
	else:
		# The input field quiz takes a single string as a test answer.
		result = _quiz.test_answer(_get_answers().back())
	_help_message.text = result.help_message
	_help_message.visible = not result.help_message.is_empty()
	
	if _error_tween and _error_tween.is_valid():
		_error_tween.kill()
	if not result.is_correct:
		_outline.modulate.a = 1.0
		_outline.add_theme_stylebox_override("panel", ERROR_OUTLINE)

		_error_tween = create_tween()
		position.y = _shake_pos
		_error_tween.tween_property(
			self,
			"position:y",
			_shake_pos,
			ERROR_SHAKE_TIME
		).from(_shake_pos + ERROR_SHAKE_SIZE).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		_error_tween.tween_property(
			_outline,
			"modulate:a",
			0.0,
			OUTLINE_FLASH_DURATION
		).set_delay(OUTLINE_FLASH_DELAY).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	else:
		_show_answer()


func _show_answer(gave_correct_answer := true) -> void:
	if _error_tween and _error_tween.is_valid():
		_error_tween.kill()
	_outline.add_theme_stylebox_override("panel", PASSED_OUTLINE if gave_correct_answer else NEUTRAL_OUTLINE)
	_outline.modulate.a = 1.0


	_result_container.show()
	_change_rect_size_to(_result_container.size)

	#Hiding choice view upon completion of the following tween
	if _size_tween and _size_tween.is_valid():
		_size_tween = create_tween()
		_size_tween.connect("finished", Callable(self, "_on_percent_size_tween_completed"))
	_size_tween.tween_property(
		_choice_container,
		"modulate:a",
		0,
		FADE_OUT_TIME
	).from(1)

	_size_tween.tween_property(
		_result_container,
		"modulate:a",
		1,
		FADE_IN_TIME
	).from(0).set_delay(FADE_OUT_TIME).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	if gave_correct_answer:
		emit_signal("quiz_passed")
	else:
		if _quiz.get_answer_count() == 1:
			_result_label.text = "The answer was:"
		else:
			_result_label.text = "The answers were:"
		_correct_answer_label.show()
		_correct_answer_label.text = _quiz.get_correct_answer_string()
		emit_signal("quiz_skipped")

func _change_rect_size_to(size: Vector2, instant := false) -> void:
	if _size_tween and _size_tween.is_valid():
		_size_tween.kill()

	if instant:
		custom_minimum_size = size
		return

	_previous_rect_size = custom_minimum_size
	_next_rect_size = size
	_percent_transformed = 0.0

	_size_tween = create_tween()
	_size_tween.connect("step_finished", Callable(self, "_on_size_tween_step"))
	_size_tween.connect("finished", Callable(self, "_on_size_tween_completed"))
	_size_tween.tween_property(
		self,
		"_percent_transformed",
		1.0,
		SIZE_CHANGE_TIME,
	).from(0.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_item_rect_changed() -> void:
	if not _error_tween or not _error_tween.is_running() or _error_tween.get_total_elapsed_time() > ERROR_SHAKE_TIME:
		_shake_pos = position.y

	if _choice_container.size.x < size.x:
		_choice_container.size.x = size.x
	if _result_container.size.x < size.x:
		_result_container.size.x = size.x

func _on_help_label_visibility_changed() -> void:
	_animating_hint = true

func _on_choice_container_minimum_size_changed() -> void:
	if _choice_container.size.y > _choice_container.get_combined_minimum_size().y:
		_choice_container.size.y = _choice_container.get_combined_minimum_size().y

	if not _result_container.visible:
		# If not animating the hint, just resize normally.
		_change_rect_size_to(_choice_container.size, !_animating_hint)

func _on_result_container_minimum_size_changed() -> void:
	if _result_container.size.y > _result_container.get_combined_minimum_size().y:
		_result_container.size.y = _result_container.get_combined_minimum_size().y

	if _result_container.visible:
		_change_rect_size_to(_result_container.size)

func _on_size_tween_step(_step: int) -> void:
	if _next_rect_size != Vector2.ZERO:
		var new_size := _previous_rect_size
		var difference := _next_rect_size - _previous_rect_size
		new_size += difference * _percent_transformed
		custom_minimum_size = new_size


func _on_percent_size_tween_completed() -> void:
	_next_rect_size = Vector2.ZERO
	_animating_hint = false


func _on_fade_tween_completed() -> void:
	# To avoid the buttons being clickable after choice view is gone.
	_choice_container.hide()
