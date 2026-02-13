extends PanelContainer

signal loading_finished()
signal faded_in()
signal faded_out()

const FADING_DURATION := 0.5
const PROGRESS_DURATION := 0.75

enum State { IDLE, LOADING, FADING_IN, FADING_OUT }

var progress_value := 0.0: set = set_progress_value

var _state: int = State.IDLE
var _tweener: Tween

@export var _progress_bar: ProgressBar


func _ready() -> void:
	_state = State.IDLE
	_progress_bar.value = 0.0

	_animate_progress()


func set_progress_value(value: float) -> void:
	progress_value = clamp(value, 0.0, 1.0)
	
	if is_inside_tree():
		_animate_progress()


func reset_progress_value() -> void:
	progress_value = 0.0
	
	if is_inside_tree():
		_progress_bar.value = progress_value


func fade_in() -> void:
	_state = State.FADING_IN
	modulate.a = 0.0
	visible = true

	if _tweener and _tweener.is_valid():
		_tweener.kill()
	_tweener = create_tween()
	_tweener.connect("finished", Callable(self, "_on_tweener_finished"))
	
	_tweener.tween_property(self, "modulate:a", 1.0, FADING_DURATION).from(0.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func fade_out() -> void:
	_state = State.FADING_OUT

	if _tweener and _tweener.is_valid():
		_tweener.kill()
	_tweener = create_tween()
	_tweener.connect("finished", Callable(self, "_on_tweener_finished"))
	
	_tweener.tween_property(self, "modulate:a", 0.0, FADING_DURATION).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func _animate_progress() -> void:
	if _state != State.IDLE:
		return
	
	_state = State.LOADING
	if _tweener and _tweener.is_valid():
		_tweener.kill()

	if _progress_bar.value == progress_value:
		_state = State.IDLE
		emit_signal("loading_finished")
		return

	_tweener = create_tween()
	_tweener.connect("finished", Callable(self, "_on_tweener_finished"))
	_tweener.tween_property(_progress_bar, "value", progress_value, PROGRESS_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func _on_tweener_finished() -> void:
	if _state == State.FADING_IN:
		emit_signal("faded_in")

		_state = State.IDLE
		_animate_progress()
	elif _state == State.FADING_OUT:
		emit_signal("faded_out")

		_state = State.IDLE
		visible = false

	elif _state == State.LOADING:
		if _progress_bar.value == _progress_bar.max_value:
			emit_signal("loading_finished")

		_state = State.IDLE
		fade_out()
