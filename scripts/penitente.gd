extends KinematicBody2D

var king

var dist_king = 150.0
var vel = Vector2(0.0, 0.0)
var speed = 10.0
var sp_multiplier = 5.0

var atq = 30
var life = 100

func _ready():
	get_node("damage").add_to_group("enemy")
	get_node("hitbox").add_to_group("hitbox")
	king = get_tree().get_root().get_node("Node2D/king")
	set_fixed_process(true)

func _fixed_process(delta):
	walk() #Make it walk
	#If it is close the king, make it go faster
	if (abs(get_pos().x - king.get_pos().x) < dist_king):
		get_node("anim").set_speed(2.0) #Anim faster
		move(vel * sp_multiplier * delta)
	else:
		#In any other case, normal speed
		get_node("anim").set_speed(1.0)
		move(vel * delta)

func walk():
	#Get current time. Each frame has 0.1
	var frame = get_node("anim").get_current_animation_pos()
	#If it not walking, don't move it
	if (frame >= 0.4 and frame <= 0.6 or frame >= 1.1):
		vel.x = 0.0
	else: #in other case move it
		if (get_pos().x > king.get_pos().x):
			get_node("Sprite").set_flip_h(false)
			vel.x = -speed
		else:
			get_node("Sprite").set_flip_h(true)
			vel.x = speed

#Always can deal damage
func can_deal_damage():
	return true 

func get_atq():
	return atq

func damage(swatq):
	life -= swatq
