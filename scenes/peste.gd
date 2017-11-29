extends Node2D

#Each image has different dimensions, so we will load each one individually
var nombres = ["pose", "ataque1",]
var frames = [6, 16] #Number of frames of each texture
var texturas = [] #Stores all textures

var attack_time = 5.0 #Each 5 seconds, attack
var elapsed_time = 0.0 #Elapsed time
var atq_elapsed_time = 0.0 #Counter of atq elapsed time

#Witches!
var witch = load("res://scenes/witch.tscn")

var king

var atq = 50
var life = 200
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
	#Load textures
	for name in nombres:
		texturas.append(load("res://graphics/enemies/peste/"+name+".png"))
	set_fixed_process(true)

func _fixed_process(delta):
	#Start stuff once we are in-boss
	if (king.is_in_boss()):
		elapsed_time += delta
		#If we are not damaged, start doing things
		if (not is_damaged):
			#Start attack...
			if (elapsed_time >= attack_time):
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
			
		else:
			#If we have been attacked,
			if (life > 0):
				#Alpha modulation allows player to see it has hit the clown
				get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time)))
				#Reocover from hit
				if (elapsed_time > damagetime):
					elapsed_time = 0.0
					vulnerable = false
					is_damaged = false
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			else:
				#If we are dead, stop process and delete after animation finishes
				if (elapsed_time > get_node("anim").get_current_animation_length()):
					set_fixed_process(false)
					queue_free()

func do_atq():
	var r = randf()
	#Probability 2/3, call witches
	if (r < 0.66):
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
		w2.set_pos(Vector2(300 + 100 * r2, -(randf() * 100)))
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
		is_damaged = true
		elapsed_time = 0.0
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
