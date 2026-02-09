extends PanelContainer

var values := []: set = set_values
var _tween: Tween

@onready var _label := $Label as Label


func _ready() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate:a", 0.25, 1.5).from(1.0)


func set_values(new_values: Array) -> void:
	values = new_values
	if not is_inside_tree():
		await self.ready

	_label.text = " ".join(PackedStringArray(new_values))
