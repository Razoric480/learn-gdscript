extends PanelContainer

var values := []: set = set_values
var _tween: Tween

@onready var _label := $Label as Label


func set_values(new_values: Array) -> void:
	values = new_values
	if not is_inside_tree():
		await self.ready

	var message = " ".join(PackedStringArray(new_values))

	if _label.text == message:
		return

	_label.text = message

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate:a", 0.25, 1.5).from(1.0)
