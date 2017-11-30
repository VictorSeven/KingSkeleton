extends Node2D

#Each image has different dimensions, so we will load each one individually
var nombres = ["Caminando", "Ataque", "hit1", "Muerte"]
var frames = [8, 8, 2, 6] #Number of frames of each texture
var texturas = [] #Stores all textures

var king #An instance of king

var detection_distance = 500

var active = false #Is active?
var walking = false #Is walking?
var activate_start_time = 0.6 #Time to play anim
var elapsed_time = 0.0 #Elapsed time

var speed = 10.0
var atq = 20
var vel = Vector2(0.0, 0.0)

var life = 60
var kill = false

func _ready():
	king = get_tree().get_root().get_node("Node2D/king") #Get the king
	get_node("hitbox").add_to_group("hitbox")
	get_node("atq").add_to_group("enemy")
	# Load all textures:
	for name in nombres:
		texturas.append(load("res://graphics/enemies/genoma/"+name+".png"))
	#get_node("Sprite").set_texture(texturas[0]) #Set idle text
	#get_node("Sprite").set_hframes(1)
	set_fixed_process(true)

func _fixed_process(delta):
	#Activate only inside area
	if (abs(get_pos().x - king.get_pos().x) < detection_distance):
		#During the activation/attack/death anim, we're blocked:
		if (not walking):
			vel.x = 0.0
			#count time...
			elapsed_time += delta
			if (elapsed_time > activate_start_time):
				#And then recover action
				if (not kill):
					#Still alive, then continue walking
					walking = true
					change_anim("walk", 0)
				else:
					queue_free() #Not alive -> delete node
		else:
			movement(delta) #Move
		set_pos(get_pos() + vel * delta)

func movement(delta):
	if (king.get_pos().x < get_pos().x):
		vel.x = -speed
		get_node("Sprite").set_flip_h(false)
	else:
		vel.x = speed
		get_node("Sprite").set_flip_h(true)

#Here we need also the index of the texture
func change_anim(newanim, index):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		set_sprite_text(index)
		get_node("anim").play(newanim) #Change it!

#To put the correct texture to the sprite
func set_sprite_text(index):
	get_node("Sprite").set_texture(texturas[index]) #Set the correct texture
	get_node("Sprite").set_hframes(frames[index]) #Say how many frames it has

func get_atq():
	#If this function is invoked, we are attacking, so animate
	atq_anim() 
	return atq

#Called by sword to deal damage
func damage(points):
	#Any action different from walking -invulnerable
	if (walking):
		life -= points
		print(life)
		if (life > 0):
			get_node("player").play("damage")
			change_anim("damage", 2)
			#Use this to block the enemy during this animation:
			#is_damaged = true #Block
			walking = false
			elapsed_time = 0.0
			activate_start_time = 1.0 #Set block time
		else:
			get_node("player").play("death")
			change_anim("death", 3)
			walking = false
			kill = true 
			elapsed_time = 0.0
			activate_start_time = 1.0 #Set block time

func can_deal_damage():
	return not kill

#Attack animation
func atq_anim():
		change_anim("attack", 1)
		#Use this to block the enemy during this animation:
		walking = false
		elapsed_time = 0.0
		#Current animation is attack, so gets its length
		activate_start_time = get_node("anim").get_current_animation_length()
