extends Sprite

var atq = 0

var vel
var maxvel = 200.0

func _ready():
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func _fixed_process(delta):
	set_pos(get_pos() + delta * vel)

func init(payasoatq, king_pos, payasopos):
	atq = payasoatq
	vel = maxvel * (king_pos - payasopos).normalized()

func can_deal_damage():
	return true

func get_atq():
	return atq

func _on_hitbox_area_enter( area ):
	if (area.get_parent().is_in_group("king")):
		queue_free()

func _on_hitbox_body_enter( body ):
	queue_free()
