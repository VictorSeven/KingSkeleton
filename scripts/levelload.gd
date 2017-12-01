extends Node2D

var singleton
var scene_paths = ["res://scenes/Town.tscn", "res://scenes/Catacombs.tscn", "res://scenes/Castle.tscn", "res://scenes/ThroneRoom.tscn"]
var current_scene = 1

func _ready():
	singleton = get_node("/root/global")
	singleton.fade_in()


func _on_radar_area_enter( area ):
	if (area.is_in_group("king")):
		singleton.goto_scene(scene_paths[current_scene])
		current_scene += 1
