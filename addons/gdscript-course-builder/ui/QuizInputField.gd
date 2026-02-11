@tool
extends Control

enum TypeOptions { STRING, FLOAT, INT }

var _quiz: QuizInputField

@export var _correct_answer: LineEdit


func _ready() -> void:
	_correct_answer.text_changed.connect(_on_correct_answer_text_changed)


func setup(quiz: QuizInputField) -> void:
	_quiz = quiz
	if not is_inside_tree():
		await self.ready

	_correct_answer.text = str(quiz.valid_answer)


func _on_correct_answer_text_changed(new_text: String) -> void:
	_quiz.valid_answer = new_text
	_quiz.emit_changed()
