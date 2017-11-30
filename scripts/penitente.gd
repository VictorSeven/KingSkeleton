extends KinematicBody2D

var king #King instance

#Death effect
var death_effect = load("res://scenes/death_effect.tscn")

var dist_king = 150.0 #Distance to king
var vel = Vector2(0.0, 0.0)
var speed = 10.0
var sp_multiplier = 5.0 #To move faster when it is close

#Stats
var atq = 30
var life = 100

var is_damaged = false
var elapsed_time = 0.0
var damagetime = 0.5

func _ready():
	#Get all info from scene
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
	
	if (is_damaged):
		elapsed_time += delta
		get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time)))
		if (elapsed_time > damagetime):
			is_damaged = false
			elapsed_time = 0.0
			get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))

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
	return not is_damaged 

func get_atq():
	return atq

func damage(swatq):
	if (not is_damaged):
		life -= swatq
		is_damaged = true
		if (life < 0):
			#Create a death effect that will destroy this node
			set_fixed_process(false)
			get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 0.0))
			var new_effect = death_effect.instance()
			add_child(new_effect)
