extends PanelContainer

@export var current = 0

func switch_to(node_name:String):
	for child:Node in get_children():
		child.visible = child.name == str(node_name)
