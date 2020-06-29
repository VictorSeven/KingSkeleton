extends Node2D

var maxvel = 3.0
var left = Vector2(-1.0, 0.0)
var atq = 10
var laugh = false
var death_effect = load("res://scenes/death_effect.tscn")
var potion_scene = load("res://scenes/potion.tscn")

func _ready():
	get_node("hitbox").add_to_group("enemy")
	get_node("hitbox").add_to_group("hitbox")
	set_fixed_process(true)

func init(vel):
	maxvel = vel

func can_deal_damage():
	return true

func get_atq():
	return atq

func damage(swatq):
	var r = randf()
	#Probability 2/3, call witches
	if (r < 0.6):
		var new_potion = potion_scene.instance()
		new_potion.set_global_pos(get_global_pos())
		get_parent().get_parent().add_child(new_potion)
		
	
	var new_effect = death_effect.instance()
	set_fixed_process(false)
	add_child(new_effect)

func _fixed_process(delta):
	set_pos(get_pos() + delta * maxvel * left)
	#When we have moved a bit,
	if (get_pos().x <= -350):
		#Then laugh if we haven't yet
		if (not laugh):
			get_node("player").play("witch_laugh")
			laugh = true
		#Destroy when far away
		if (get_pos().x < -700):
			queue_free()