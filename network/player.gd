extends Control

@export var player_name:String:
	set(new_player_name):
		player_name = new_player_name
		$label.text = new_player_name
