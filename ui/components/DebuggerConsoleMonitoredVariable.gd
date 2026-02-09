extends PanelContainer

var values := []: set = set_values

@onready var _label := $Label as Label
@onready var _tween := $Tween as Tween


func set_values(new_values: Array) -> void:
	values = new_values
	if not is_inside_tree():
		await self.ready

	var message = " ".join(PackedStringArray(new_values))

	if _label.text == message:
		return

	_label.text = message

	_tween.stop_all()
	_tween.interpolate_property(self, "self_modulate:a", 1.0, 0.25, 1.5)
	_tween.start()
