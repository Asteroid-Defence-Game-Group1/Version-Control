extends Node

var is_paused: bool = false

# Signal to notify anyone listening that pause changed
signal pause_toggled(paused)

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	emit_signal("pause_toggled", is_paused)
