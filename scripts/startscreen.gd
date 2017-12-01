extends Node2D

var singleton 
var menu = false
var creditos = false
var up = false 
var down = false
var xpos = -30
var ypos = [22, 42, 62]
var selected_option = 0
var rect_pos = Vector2(xpos, ypos[0])
var rect_size = Vector2(60, 13)


func _ready():
	singleton = get_node("/root/global")
	pass

func _on_anim_finished():
	menu = true
	get_node("text").show()
	update()
	set_process_input(true)

func _input(event):
	if (not creditos):
		if (event.is_action_pressed("ui_down") and not down):
			if (selected_option == 0):
				selected_option = 1
			elif (selected_option == 1):
				selected_option = 2
		if (event.is_action_pressed("ui_up") and not up):
			if (selected_option == 2):
				selected_option = 1
			elif (selected_option == 1):
				selected_option = 0
		if (event.is_action_pressed("ui_accept")):
			if (selected_option == 0):
				singleton.goto_scene("res://scenes/Castle.tscn")
			elif (selected_option == 1):
				creditos = true
				get_node("creditos").show()
				get_node("text").hide()
				menu = false
			else:
				get_tree().quit()
		rect_pos = Vector2(xpos, ypos[selected_option])
		update()
	else:
		if (Input.is_action_pressed("ui_accept")):
			creditos = false
			get_node("creditos").hide()
			get_node("text").show()
			menu = true

func _draw():
	if (menu):
		draw_rect(Rect2(rect_pos, rect_size), Color(1.0, 0.0, 0.0, 0.2))