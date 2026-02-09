@tool
extends EditorPlugin

var _main_screen_plugin


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "Course Builder"


func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon("EditorPlugin", "EditorIcons")


func _enter_tree() -> void:
	_main_screen_plugin = preload("plugins/MainScreenPlugin.gd").new()
	_main_screen_plugin.plugin_instance = self
	get_editor_interface().get_editor_main_screen().add_child(_main_screen_plugin)
	_make_visible(false)


func _exit_tree() -> void:
	get_editor_interface().get_editor_main_screen().remove_child(_main_screen_plugin)


func _make_visible(visible: bool) -> void:
	_main_screen_plugin.visible = visible
