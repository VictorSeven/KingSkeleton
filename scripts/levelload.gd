extends Node2D

var singleton

func _ready():
	singleton = get_node("/root/global")
	singleton.fade_in()
