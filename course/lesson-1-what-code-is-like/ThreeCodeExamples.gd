extends Control

const COLOR_KEYWORD := Color(1, 0.094118, 0.321569)
const COLOR_QUOTES := Color(1, 0.960784, 0.25098)
const COLOR_COMMENTS := Color(0.290196, 0.294118, 0.388235)

@export var _python_code: TextEdit
@export var _js_code: TextEdit


func _ready() -> void:
	_python_code.syntax_highlighter.add_color_region("#", "", COLOR_COMMENTS, true)
	_js_code.syntax_highlighter.add_color_region("//", "", COLOR_COMMENTS, true)

	for key in ["if", "function"]:
		_js_code.syntax_highlighter.add_keyword_color(key, COLOR_KEYWORD)
	for key in ["if", "def"]:
		_python_code.syntax_highlighter.add_keyword_color(key, COLOR_KEYWORD)
