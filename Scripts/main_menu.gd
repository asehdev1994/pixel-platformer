extends Control

signal play_pressed
signal quit_pressed


func _on_play_button_pressed() -> void:
	play_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
