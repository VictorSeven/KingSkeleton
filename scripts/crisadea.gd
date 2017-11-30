extends Node2D

export var right = true #Are we looking right or left?

#Each image has different dimensions, so we will load each one individually
var nombres = ["Pose", "Ataque", "hit1"]
var frames = [8, 10, 2] #Number of frames of each texture
var texturas = [] #Stores all textures

var king #An instance of king

#Death effect
var death_effect = load("res://scenes/death_effect.tscn")

#Distance to detect player
var detection_distance = 500

var start_atq = 2.0 #Time to make attack
var atq_anim_length #Duration of attack animation
var anim_started = false #Have we started the attack?
var elapsed_time = 0.0 #Elapsed time

var life = 60
var is_damaged = false
var damage_time = 0.5 #Time to be locked by damage

#Projectile and possible directions to launch
var projectile = load("res://scenes/crisadea_projectile.tscn")
var dir1 = Vector2(-1.0, 0.0).normalized()
var dir2 = Vector2(-1.0, -0.4).normalized()

func _ready():
	randomize()
	#Flip everything if we are looking left
	if (not right):
		dir1.x = -dir1.x
		dir2.x = -dir2.x
		get_node("Sprite").set_flip_h(true)
	#Get the king
	king = get_tree().get_root().get_node("Node2D/king")
	#Configure hitbox
	get_node("hitbox").add_to_group("hitbox")
	#Get atq duration
	atq_anim_length = get_node("anim").get_animation("ataque").get_length()
	#Load all textures
	for name in nombres:
		texturas.append(load("res://graphics/enemies/crisadea/"+name+".png"))
	set_fixed_process(true)

func _fixed_process(delta):
	#Do things when we are close
	if (abs(get_pos().x - king.get_pos().x) < detection_distance):
		#If we are not damaged, attack!
		if (not is_damaged):
			atq_timer(delta)
		else:
			#In the other case, wait damage stun
			elapsed_time += delta
			if (elapsed_time > damage_time):
				change_anim("loop", 0) #Recover animation
				is_damaged = false #Stop damage
				elapsed_time = 0.0 #Reinit -because it is used also for throw

#Timer of atq
func atq_timer(delta):
	elapsed_time += delta
	#Start atq
	if (elapsed_time >= start_atq):
		get_node("anim").set_speed(1.5)
		change_anim("ataque", 1) #Change animation 
		#Once the animation have run enough, create the projectile
		if (elapsed_time > start_atq + atq_anim_length - 0.3 and not anim_started):
			anim_started = true #To avoid multiple projectile creation
			var new_projectile = projectile.instance() #Instance it
			#Get a random direction between the two
			var r = randf()
			var dir
			if (r < 0.5):
				dir = dir1
			else:
				dir = dir2
			new_projectile.init(dir)
			#Put it in the mouth of crisadea
			new_projectile.set_pos(Vector2(-14, 16))
			add_child(new_projectile) #add to scene
		elif (elapsed_time > start_atq + atq_anim_length ):
			#Once the animation finishes, go again to normal anim
			elapsed_time = 0.0
			anim_started = false
			get_node("anim").set_speed(1.0)
			change_anim("loop", 0)

#Damage logic
func damage(swatq):
	if (not is_damaged): #Avoid multiple damage
		life -= swatq
		is_damaged = true
		elapsed_time = 0.0
		#Play it if we are alive
		if (life > 0):
			change_anim("hit", 2)
		else:
			#If not, block it in idle texture...
			set_sprite_text(0)
			get_node("Sprite").set_frame(0)
			#...stop processing information...
			set_fixed_process(false)
			#and add the kill effect. This will take care
			#of freeing the node after playing
			get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 0.0))
			var new_effect = death_effect.instance()
			add_child(new_effect)

#Here we need also the index of the texture
func change_anim(newanim, index):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		set_sprite_text(index)
		get_node("anim").play(newanim) #Change it!
		#For the attack animation, play the sound!
		if (newanim == "ataque"):
			get_node("player").play("escupe")

#To put the correct texture to the sprite
func set_sprite_text(index):
	get_node("Sprite").set_texture(texturas[index]) #Set the correct texture
	get_node("Sprite").set_hframes(frames[index]) #Say how many frames it has