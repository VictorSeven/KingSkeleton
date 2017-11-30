extends Sprite

var dir 
var maxvel = 100.0

var atq = 20

func _ready():
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func _fixed_process(delta):
	set_pos(get_pos() + maxvel * delta * dir)

func init(p_dir):
	dir = p_dir

func can_deal_damage():
	return true

func get_atq():
	return atq