extends Node2D

var singleton

func _ready():
	singleton = get_node("/root/global")
	singleton.fade_in()


func _on_radar_area_enter( area ):
	if (area.is_in_group("king")):
		singleton.load_next_level()
	
