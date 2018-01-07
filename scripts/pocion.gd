extends Area2D

export var recup = 50

var x0
var y0
var y
var t

func _ready():
	t = 0.0
	x0 = get_pos().x
	y0 = get_pos().y
	add_to_group("item")
	set_fixed_process(true)

func _fixed_process(delta):
	t += delta
	y = y0 + 10.0 * sin(6.28 * 0.5 * t)
	set_pos(Vector2(x0, y))

func use_item(king):
	king.lifepoints = min(recup + king.lifepoints, king.maxlifepoints)
	king.healthbar.update()
	queue_free()