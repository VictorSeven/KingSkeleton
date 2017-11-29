extends Node2D

var maxvel = 1.0
var left = Vector2(-1.0, 0.0)
var atq = 20

func _ready():
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func init(vel):
	maxvel = vel

func can_deal_damage():
	return true

func get_atq():
	return atq

func _fixed_process(delta):
	set_pos(get_pos() + delta * maxvel * left)
	if (get_pos().x <= -700):
		queue_free()