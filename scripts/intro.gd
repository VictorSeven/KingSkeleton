extends Node2D

var singleton 
var finished

var elapsed_time = 0.0
var change = 1.0

func _ready():
	singleton = get_node("/root/global")
	set_process_input(true)

func _input(event):
	if (event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept")):
		singleton.jump_intro("res://scenes/startscreen.tscn")

func _on_anim_finished():
	singleton.jump_intro("res://scenes/startscreen.tscn")