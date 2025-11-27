extends Control

signal remove_player

@export var player_name:String:
	set(new_player_name):
		player_name = new_player_name
		$label.text = new_player_name

func _on_remove_player_button_pressed() -> void:
	emit_signal("remove_player")
