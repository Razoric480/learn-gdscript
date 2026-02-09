extends TextureRect

var duration := 1.5 + randf() * 0.5

func _ready() -> void:
	var tween := create_tween()
	
	tween.set_speed_scale(randf_range(0.9, 1.2))
	var top_pos := position - Vector2(0, randf() * 12.0 + 4.0)
	var seek_time := randf()
	var seek_t := seek_time / duration
	tween.tween_property(self, "position", top_pos, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).from(position.lerp(top_pos, seek_t))
	tween.tween_property(self, "position", position, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(duration)
