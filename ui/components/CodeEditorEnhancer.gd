# Sets options on a TextEdit for it to be more suitable as
# a text editor.
#
# Sets some colors, and adds keywords used GDScript to the
# highlight list, as well as strings and comments.
class_name CodeEditorEnhancer
extends Node

const COLOR_CLASS := Color(0.666667, 0, 0.729412)
const COLOR_MEMBER := Color(0.14902, 0.776471, 0.968627)
const COLOR_KEYWORD := Color(1, 0.094118, 0.321569)
const COLOR_QUOTES := Color(1, 0.960784, 0.25098)
const COLOR_COMMENTS := Color(0.290196, 0.294118, 0.388235)
const COLOR_NUMBERS := Color(0.922, 0.580, 0.200)
const KEYWORDS := [
	
	# Basic keywords.
	"var",
	"const",
	"func",
	"signal",
	"enum",
	"class",
	"static",
	"extends",
	"self",
	
	# Control flow keywords.
	"if",
	"elif",
	"else",
	"not",
	"and",
	"or",
	"in",
	"for",
	"do",
	"while",
	"match",
	"switch",
	"case",
	"break",
	"continue",
	"pass",
	"return",
	"is",
	
	# Godot-specific keywords.
	"onready",
	"export",
	"tool",
	"setget",
	"breakpoint",
	"remote", "sync",
	"master", "puppet", "slave",
	"remotesync", "mastersync", "puppetsync",
	
	# Primitive data types.
	"bool",
	"int",
	"float",
	"null",
	"true", "false",
	
	# Global GDScript namespace.
	"Color8",
	"ColorN",
	"abs",
	"acos",
	"asin",
	"assert",
	"atan",
	"atan2",
	"bytes_to_var",
	"cartesian2polar",
	"ceil",
	"char",
	"clamp",
	"convert",
	"cos",
	"cosh",
	"db_to_linear",
	"decials",
	"move_toward",
	"deg_to_rad",
	"dict_to_inst",
	"ease",
	"expo",
	"floor",
	"fmod",
	"fposmod",
	"funcref",
	"hash",
	"inst_to_dict",
	"instance_from_id",
	"inverse_lerp",
	"is_inf",
	"is_nan",
	"len",
	"lerp",
	"linear_to_db",
	"load",
	"log",
	"max",
	"min",
	"nearest_po2",
	"parse_json",
	"polar2cartesian",
	"pow",
	"preload",
	"print",
	"print_stack",
	"printerr",
	"printraw",
	"prints",
	"printt",
	"rad_to_deg",
	"randf_range",
	"rand_seed",
	"randf",
	"randi",
	"randomize",
	"range",
	"remap",
	"round",
	"seed",
	"sign",
	"sin",
	"sinh",
	"sqrt",
	"snapped",
	"str",
	"str_to_var",
	"tan",
	"tanh",
	"JSON.new().stringify",
	"type_exists",
	"typeof",
	"validate_json",
	"var_to_bytes",
	"var_to_str",
	"weakref",
	"wrapf",
	"wrapi",
	"yield",
	
	"PI", "TAU", "INF", "NAN",
	
]

# Enhances a TextEdit to better highlight GDScript code.
static func enhance(text_edit: TextEdit) -> void:
	text_edit.syntax_highlighter = CodeHighlighter.new()
	#TODO text_edit.show_line_numbers = true
	text_edit.draw_tabs = true
	text_edit.draw_spaces = true
	text_edit.scroll_smooth = true
	text_edit.caret_blink = true
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

	(text_edit.syntax_highlighter as CodeHighlighter).add_color_region('"', '"', COLOR_QUOTES)
	(text_edit.syntax_highlighter as CodeHighlighter).add_color_region("'", "'", COLOR_QUOTES)
	(text_edit.syntax_highlighter as CodeHighlighter).add_color_region("#", "", COLOR_COMMENTS, true)

	for classname in ClassDB.get_class_list():
		(text_edit.syntax_highlighter as CodeHighlighter).add_keyword_color(classname, COLOR_CLASS)
		for member in ClassDB.class_get_property_list(classname):
			for key: String in member:
				(text_edit.syntax_highlighter as CodeHighlighter).add_keyword_color(key, COLOR_MEMBER)

	for keyword: String in KEYWORDS:
		(text_edit.syntax_highlighter as CodeHighlighter).add_keyword_color(keyword, COLOR_KEYWORD)
