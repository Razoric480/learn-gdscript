extends TextureRect

var duration := 1.5 + randf() * 0.5

@onready var _tween := $Tween as Tween

func _ready() -> void:
	_tween.playback_speed = randf_range(0.9, 1.2)
	var top_pos := position - Vector2(0, randf() * 12.0 + 4.0)
	_tween.interpolate_property(self, "position", position, top_pos, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.interpolate_property(self, "position", top_pos, position, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT, duration)
	_tween.start()
	_tween.seek(randf())
