extends Node2D

#Each image has different dimensions, so we will load each one individually
var nombres = ["pose", "ataque1",]
var frames = [6, 16] #Number of frames of each texture
var texturas = [] #Stores all textures

var attack_time = 10.0
var elapsed_time = 0.0
var atq_elapsed_time = 0.0

var king

var atq = 50

var life = 30
var is_damaged = false
var vulnerable = true
var attacking = false
var damagetime = 1.5

func _ready():
	king = get_tree().get_root().get_node("Node2D/king")
	get_node("hitbox").add_to_group("hitbox")
	get_node("atq").add_to_group("enemy")
	for name in nombres:
		texturas.append(load("res://graphics/enemies/peste/"+name+".png"))
	set_fixed_process(true)

func _fixed_process(delta):
	if (king.is_in_boss()):
		elapsed_time += delta
		if (not is_damaged):
			
			if (elapsed_time >= attack_time):
				if (not vulnerable):
					vulnerable = true
					atq_elapsed_time = 0.0
					do_atq()
				else:
					atq_elapsed_time += delta
					if (atq_elapsed_time > get_node("anim").get_current_animation_length()):
						vulnerable = false
						elapsed_time = 0.0
						change_anim("pose", 0)
			
		else:
			if (life > 0):
				#Alpha modulation allows player to see it has hit the clown
				get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time_damage)))
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
	if (r < 0.66):
		change_anim("call", 1) #Call witches!
	else:
		#This animation includes movement of area that makes the attack!
		#Also it includes change of textures, so hold it manually
		get_node("Sprite").set_hframes(7)
		get_node("anim").play("escupe")

func can_deal_damage():
	return not is_damaged

func damage(swatq):
	if (vulnerable and not is_damaged):
		life -= swatq
		is_damaged = true
		elapsed_time = 0.0
		if (life < 0):
			pass

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
