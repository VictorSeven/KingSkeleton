extends Node2D

var king #King instance

var textures #To store the texture
var paths = ["Vuelo.png", "Hit1.png", "Muerte.png"] #Texture path
var hframes = [6, 2, 4] #Number of frames of each one of the textures

var radar = 200 #Radious of detection
var flying = false #To see if it is flying

var vel = Vector2(0.0, 0.0)
var maxvel = 100.0

var noise = Vector2(0.0, 0.0) #Random force
var noise_intensity = 0.45 #Intensity of random force

var damaged = false #If this is damaged
var elapsed_time = 0.0 #Elapsed time

#Parameters
var life = 50
var atq = 20

func _ready():
	randomize() #To get good random numbers
	
	#This is enemy and also hitbox
	get_node("hitbox").add_to_group("enemy")
	get_node("hitbox").add_to_group("hitbox")
	
	#Get the king
	king = get_tree().get_root().get_node("Node2D/king")
	
	#Load all the textures
	textures = []
	for p in paths:
		textures.append(load("res://graphics/enemies/inkelago/" + p))
	
	set_fixed_process(true) #Start checking

func _fixed_process(delta):
	#Wait until player is near enough
	if (not flying):
		if (get_pos().distance_squared_to(king.get_pos()) < radar*radar):
			flying = true
			play_anim("fly", 0)
			get_node("anim").set_speed(1.5) #Animation speed
	else:
		if (not damaged):
			#If we are not block, move
			move()
			set_pos(get_pos() + vel * delta)
		else:
			#Block it so it does not move
			elapsed_time += delta
			if (elapsed_time > get_node("anim").get_animation("hit").get_length()*2):
				if (life > 0):
					#If we are still alive, then return to stuff
					play_anim("fly", 0)
					damaged = false 
				else:
					#In any other case, kill it!
					queue_free()

func move():
	var frame = get_node("anim").get_current_animation_pos()
	#Move it towards to player
	if (frame < 0.4):
		var force = (1.0-noise_intensity) * (king.get_pos()-get_pos()).normalized()
		vel = maxvel * (noise + force).normalized()
		if (vel.x < 0):
			get_node("Sprite").set_flip_h(true)
		elif (vel.x > 0):
			get_node("Sprite").set_flip_h(false)
	else:
		noise = noise_intensity * Vector2(randf(),randf())
		vel = Vector2(0.0, 0.0)

#Get an animation and play it using information from arrays
func play_anim(name, index):
	get_node("Sprite").set_texture(textures[index])
	get_node("Sprite").set_hframes(hframes[index])
	get_node("anim").play(name)

func can_deal_damage():
	return not damaged

func get_atq():
	return atq

func damage(swatq):
	life -= swatq
	elapsed_time = 0.0 #Set elapsed time for animations
	#If alive, play hit animation.
	if (life > 0):
		play_anim("hit", 1)
		damaged = true
	#If nt, block it with damaged var and kill it
	else:
		play_anim("death", 2)
		damaged = true