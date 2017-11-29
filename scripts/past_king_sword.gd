extends Node2D

var gira
var my_king
var speed = 400.0
var elapsed_time = 0.0
var w = 6.0
var phi = 3.14159 / 2.0
var basepos

var r
var direction
var clockwise
var minx
var maxx
var loffset
var roffset
var atq = 30

func _ready():
	basepos = get_pos()
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func init_circular(c, r0, king):
	gira = true
	r = r0
	clockwise = c
	get_node("linear").hide()
	get_node("circ").show()
	my_king = king

func init_linear(c, mx, nx, king):
	loffset = 20.0
	roffset = 10.0
	gira = false
	if (c):
		direction = Vector2(1.0, 0.0)
	else:
		direction = Vector2(-1.0 ,0.0)
		get_node("linear").set_flip_h(true)
	minx = mx - loffset
	maxx = nx + roffset
	get_node("linear").show()
	get_node("circ").hide()
	my_king = king

func _fixed_process(delta):
	if (gira):
		elapsed_time += delta
		if (clockwise):
			set_pos(basepos + r*Vector2(-cos(elapsed_time*w+phi), sin(elapsed_time*w+phi)))
		else:
			set_pos(basepos + r*Vector2(cos(elapsed_time*w+phi), sin(elapsed_time*w+phi)))
		if (elapsed_time*w > 2.0*PI):
			set_fixed_process(false)
			queue_free()
	else:
		set_pos(get_pos() + delta * speed * direction)
		if (get_pos().x < minx or get_pos().x > maxx):
			set_fixed_process(false)
			my_king.sword_finished()


func can_deal_damage():
	return true

func get_atq():
	return atq