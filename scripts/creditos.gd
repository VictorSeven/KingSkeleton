extends Node2D

var singleton

func _ready():
	singleton = get_node("/root/global")


func _on_anim_finished():
	singleton.goto_scene("res://scenes/startscreen.tscn")
