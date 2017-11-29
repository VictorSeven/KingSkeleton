extends Node2D

var gira
var speed = 150
var elapsed_time = 0.0
var w = 20.0
var phi = 3.14159 / 2.0
var basepos
var r = 100.0
var direction
var clockwise
var minx
var maxx
var atq 

func _ready():
	get_node("hitbox").add_to_group("enemy")
	basepos = get_parent().get_pos()
	set_fixed_process(true)

func init_circular(c):
	gira = true
	clockwise = c
	get_node("linear").hide()
	get_node("circ").show()

func init_linear(c, mx, nx):
	gira = false
	if (c):
		direction = Vector2(1.0, 0.0)
	else:
		direction = Vector2(-1.0 ,0.0)
		get_node("linear").set_flip_h(true)
	minx = mx
	maxx = nx
	get_node("linear").show()
	get_node("circ").hide()

func _fixed_process(delta):
	if (gira):
		elapsed_time += delta
		if (clockwise):
			set_pos(basepos + r*Vector2(cos(elapsed_time*w+phi), sin(elapsed_time*w+phi)))
		else:
			set_pos(basepos + r*Vector2(-cos(elapsed_time*w+phi), sin(elapsed_time*w+phi)))
		if (elapsed_time*w > 2.0*PI):
			set_fixed_process(false)
			queue_free()
	else:
		set_pos(get_pos() + delta * speed * direction)
		if (get_pos().x < minx or get_pos().x > maxx):
			set_fixed_process(false)
			get_parent().sword_finished()

func can_deal_damage():
	return true

func get_atq():
	return atq