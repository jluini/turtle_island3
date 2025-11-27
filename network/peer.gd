extends Control
class_name Peer

@export var peer_id:int = 0

@export var player_name:String:
	set(new_player_name):
		player_name = new_player_name
		$h_box_container/players.get_children()[1].player_name = new_player_name
