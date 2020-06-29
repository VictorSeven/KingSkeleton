extends Node2D

#Each image has different dimensions, so we will load each one individually
var nombres = ["pose", "ataque1",]
var frames = [6, 16] #Number of frames of each texture
var texturas = [] #Stores all textures

var attack_time = 5.0 #Each 5 seconds, attack
var elapsed_time = 0.0 #Elapsed time
var atq_elapsed_time = 0.0 #Counter of atq elapsed time
var damage_elapsed_time = 0.0 #Counter of time we did nothing

#Witches!
var witch = load("res://scenes/witch.tscn")
#Healtbar!
var path_to_healthbar = "Node2D/CanvasLayer_HUD/GridContainer/EnemyHUD/Healthbar"
var healthbar 

var king

var atq = 30
var life = 100
var is_damaged = false
var vulnerable = false #Can I attack it? Only when he calls/spit
var damagetime = 1.5

func _ready():
	randomize() #Start random stuff
	#Get king
	king = get_tree().get_root().get_node("Node2D/king")
	#Set the hitboxes
	get_node("hitbox").add_to_group("hitbox")
	get_node("atq").add_to_group("enemy")
	#Load healthbar
	healthbar = get_tree().get_root().get_node(path_to_healthbar)
	healthbar.target = self
	#Load textures
	for name in nombres:
		texturas.append(load("res://graphics/enemies/peste/"+name+".png"))
	set_fixed_process(true)

func _fixed_process(delta):
	#Start stuff once we are in-boss
	if (king.is_in_boss()):
		healthbar.show()
		elapsed_time += delta
		#Start attack...
		if (elapsed_time >= attack_time and life > 0):
			#If vulnerable = true, then we are yet attacking
			if (not vulnerable):
				vulnerable = true
				atq_elapsed_time = 0.0
				do_atq() #Select attack
			else:
				#In this case see when the atq animation finishes
				atq_elapsed_time += delta
				if (atq_elapsed_time > get_node("anim").get_current_animation_length()):
					vulnerable = false #Stop attack
					elapsed_time = 0.0 #Reinit counter
					change_anim("pose", 0)
					#get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			
		#If we have been attacked,
		if (is_damaged):
			damage_elapsed_time += delta
			if (life > 0):
				#Alpha modulation allows player to see it has hit the clown
				get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(damage_elapsed_time)))
				#Reocover from hit
				if (damage_elapsed_time > damagetime):
					is_damaged = false
					damage_elapsed_time = 0.0
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			else:
				#If we are dead, stop process and delete after animation finishes
				if (damage_elapsed_time > get_node("anim").get_current_animation_length()):
					#Unlock the camera
					#king.get_node("camera").set_limit(MARGIN_RIGHT, 10000)
					king.kill_boss()
					#Stop and 
					set_fixed_process(false)
					queue_free()

func do_atq():
	var r = randf()
	#Probability 2/3, call witches
	if (r < 0.6):
		change_anim("call", 1) #Call witches!
		#Two witches
		var w1 = witch.instance()
		var w2 = witch.instance()
		#Random speeds
		var r1 = randf()
		var r2 = randf()
		w1.init(70.0 * (1.0 + r1) )
		w2.init(90.0 * (1.0 + r2) )
		#Start at random heigth also
		w1.set_pos(Vector2(300 + 100 * r1, -(randf() * 70)))
		w2.set_pos(Vector2(450 + 100 * r2, -(randf() * 100)))
		#Add them
		add_child(w1)
		add_child(w2)
		#Play the sound of invoke
		get_node("player").play("witch_attack")
		
	else:
		#This animation includes movement of area that makes the attack!
		#Also it includes change of textures, so hold it manually
		get_node("Sprite").set_hframes(7)
		get_node("anim").play("escupe")

func can_deal_damage():
	return not is_damaged

func get_atq():
	return atq

func damage(swatq):
	#Damage only when it is not vulnerable
	if (vulnerable and not is_damaged):
		life -= swatq 
		healthbar.update()
		is_damaged = true
		damage_elapsed_time = 0.0
		if (life < 0):
			#Change texture to pose and play death anim
			change_anim("death", 0)

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

func get_health():
	return life
