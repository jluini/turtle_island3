extends Control
class_name Peer

signal add_player(peer_id:int, player_name:String)
#signal remove_player(peer_id:int, player_name:String)

@export var peer_id:int = 0

@export var player_name:String:
	set(new_player_name):
		player_name = new_player_name
		$h_box_container/players.get_children()[0].player_name = new_player_name

func _on_player_remove_player() -> void:
	pass # Replace with function body.
	print("remove")

func _on_add_player_button_pressed() -> void:
	var new_player_name = $h_box_container/players/spectator/text_edit.text
	emit_signal("add_player", peer_id, new_player_name)
