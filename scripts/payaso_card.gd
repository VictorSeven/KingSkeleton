extends Sprite

var maxvel = 100.0
var dir = Vector2(1.0, 0.5).normalized()
var atq

func _ready():
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func _fixed_process(delta):
	var animpos = get_node("anim").get_current_animation_pos()
	if (0.1 < animpos and animpos <= 0.3):
		dir.x = abs(dir.x)
	elif(0.6 < animpos and animpos <= 0.9):
		dir.x = -abs(dir.x)
	set_pos(get_pos() + dir * maxvel * delta)

func init(texture, pos, cardatq):
	atq = cardatq
	set_texture(texture)
	set_pos(pos)

func can_deal_damage():
	return true

func get_atq():
	return atq

func _on_hitbox_area_enter( area ):
	if (area.get_parent().is_in_group("king")):
		queue_free()


func _on_hitbox_body_enter( body ):
	queue_free()
