extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#Each image has different dimensions, so we will load each one individually
var nombres = ["Caido", "Levantamiento", "Caminando", "Ataque", "hit1", "Muerte"]
var frames = [1, 3, 8, 8, 2, 6] #Number of frames of each texture
var texturas = [] #Stores all textures

var king #An instance of king

export var activation_dist = 150.0 #Distance at which the enemy activates
var active = false #Is active?
var walking = false #Is walking?
var activate_start_time = 0.6 #Time to play anim
var elapsed_time = 0.0 #Elapsed time

var speed = 10.0
var atq = 20
var vel = Vector2(0.0, 0.0)

var life = 30
var kill = false

func _ready():
	add_to_group("enemy")
	king = get_tree().get_root().get_node("Node2D/king")
	# Load all textures:
	for name in nombres:
		texturas.append(load("res://graphics/enemies/genoma/"+name+".png"))
	get_node("Sprite").set_texture(texturas[0]) #Set idle text
	get_node("Sprite").set_hframes(1)
	set_fixed_process(true)

func _fixed_process(delta):
	if (not active):
		#Check activation
		if (get_pos().distance_squared_to(king.get_pos()) < activation_dist * activation_dist):
			#Update shape of collision. Hitbox is the full body here
			get_node("col").get_shape().set_extents(Vector2(18,28))
			get_node("hitbox/hitcol").get_shape().set_extents(Vector2(18,28))
			change_anim("activate", 1) #Play animation
			active = true #Make active
	else:
		#During the activation/attack/death anim, we're blocked:
		if (not walking):
			vel.x = 0.0
			#count time...
			if (elapsed_time < activate_start_time):
				elapsed_time += delta
			else: 
				#And then recover action
				if (not kill):
					#Still alive, then continue walking
					walking = true
					change_anim("walk", 2)
				else:
					queue_free() #Not alive -> delete node
		else:
			movement(delta) #Move
	move(vel * delta)

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
	return atq

#Called by sword to deal damage
func damage(points):
	#Any action different from walking -invulnerable
	if (walking):
		life -= points
		print(life)
		if (life > 0):
			change_anim("damage", 4)
			#Use this to block the enemy during this animation:
			#is_damaged = true #Block
			walking = false
			elapsed_time = 0.0
			activate_start_time = 1.0 #Set block time
		else:
			change_anim("death", 5)
			walking = false
			kill = true 
			elapsed_time = 0.0
			activate_start_time = 1.0 #Set block time

func can_deal_damage():
	return (walking)

#Attack animation when collides with player
func _on_atq_area_enter( area ):
	if (area.get_parent().get_name() != "king"):
		change_anim("attack", 3)
		#Use this to block the enemy during this animation:
		walking = false
		elapsed_time = 0.0
		#Current animation is attack, so gets its length
		activate_start_time = get_node("anim").get_current_animation_length()

