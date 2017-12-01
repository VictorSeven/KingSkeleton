extends Node2D

var singleton

#Time counters
var elapsed_time = 0.0 
var elapsed_time_d = 0.0

var damagetime = 2.0 #Time to be damaged
var default_atqtime = 3.0 #Default time between attacks
var atqtime = default_atqtime #Time between attacks

#To save instance of the thrown sword
var sword = load("res://scenes/past_king_sword.tscn")
var newsword

var king #An instance of king

#Parameters
var life = 250 
var atq = 40
var speed = 200.0

var vulnerable = false #Can the enemy be attacked?
var is_damaged = false #Is it damaged?
var right = false #Looking to right

var throwing_sword = 0 #0 = not throwing, 1 = throwing linear, 2 = throwing circular
var go_recover_sword = false #Moving to recover the sword
var taking_sword_out = false  #Trying to get that sword out

#Points where the sword will block: these are practical screen limits
export var ldist = 400
export var rdist = 400

func _ready():
	singleton = get_node("/root/global")
	randomize()
	set_z(1) #The king must be always in front of the sword
	king = get_tree().get_root().get_node("Node2D/king") #Get the king
	#This is hitbox and enemy
	get_node("hitbox").add_to_group("hitbox")
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func _fixed_process(delta):
	#Wait until we are in boss
	if (king.is_in_boss()):
		elapsed_time += delta
		#If we are not vulnerable, control attacks
		if (not vulnerable):
			#If we are doing nothing, then we are waiting for next attack
			if (not go_recover_sword and throwing_sword == 0):
				check_look() #Change direction I am looking at -to the player
				#Atq timer
				if (elapsed_time > atqtime):
					elapsed_time = 0.0
					do_atq()
			#If we are doing something, then see what is...
			else:
				#Going to recover the sword
				if (go_recover_sword):
					change_anim("go_take_sword") #Put slide anim 
					go_recover(delta) #Move king towards sword
				#Not going to recover it?
				else:
					#Then we may be tackling
					if (throwing_sword == 3):
						body_atq(delta)
					#If we are not tackling, we are waiting to finish our sword-throw animation
					elif (elapsed_time > get_node("anim").get_current_animation_length()):
						elapsed_time = 0.0
						#If we are doing circular throw, then we are finished and start again from the beginning
						if (throwing_sword == 2):
							throwing_sword = 0
							change_anim("pose")
		else:
			#The remaining case, throwing_sword = 1, is activated by the sword, making the king vulnerable (trying to take out sword)
			#So, it can be damaged
			if (is_damaged):
				elapsed_time_d += delta #Start counting the damage counter
				#If we are still alive,
				if (life > 0):
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time_d))) #Visual effect of damage
					#Once we have finished the effect, stop modulating color channel and unset damage
					if (elapsed_time_d > damagetime):
						is_damaged = false 
						elapsed_time_d = 0.0
						get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
				else:
					#If we are dead, wait until the animation finishes (and a bit more) to free node
					if (elapsed_time_d > get_node("anim").get_current_animation_length() + 0.5):
						set_fixed_process(false)
						singleton.load_next_level()
			#Whether it is damaged or not, the elapsed time can still go on... 
			#It is vulnerable while he is trying to take sword out, OR during the animation while he finally takes it
			if (elapsed_time > get_node("anim").get_current_animation_length() and life > 0):
				#If we are taking the sword out
				if (taking_sword_out):
					taking_sword_out = false #Finish doing this,
					change_anim("take_sword") #Put the animation to take sword
					elapsed_time = 0.0
				else:
					#If not, then we have finished taking sword out and then can put the correct modulation to sprite
					#and return again from the beginning
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
					elapsed_time = 0.0 
					vulnerable = false
					is_damaged = false 
					change_anim("pose")

#Looks always to the player
func check_look():
	if (king.get_pos().x > get_pos().x):
		right = true
		get_node("hitbox").set_pos(Vector2(-16,44))
	else:
		right = false
		get_node("hitbox").set_pos(Vector2(14,44))
	get_node("Sprite").set_flip_h(not right)


#Do the attacks
func do_atq():
	var r = randf()
	#With 50% chance, circular sword attack will happen
	if (r < 0.5):
		change_anim("ataque2") #Put the anim
		atqtime = default_atqtime #The next attack will happen at the default time
		throwing_sword = 2 #Set its marker
		#Instance the sword
		newsword = sword.instance()
		newsword.init_circular(right, 100.0, self) #Set it to circular motion
		newsword.set_pos(get_pos() - Vector2(0.0, 70.0)) #Adjust initial pos
		get_parent().add_child(newsword) #Add to scene
	#With 20% chance, linear sword will happen
	elif (r < 0.7):
		atq = 20 #Modify king's attack so the combo sword + king = 50 (in case you receive both)
		change_anim("ataque2") #Put the anim
		atqtime = default_atqtime #The next attack will happen at the default time
		throwing_sword = 1 #Set the marker
		#Linear sword instance
		newsword = sword.instance()
		newsword.init_linear(right, ldist, rdist, self)
		newsword.set_pos(get_pos() + Vector2(0.0, 22.0))
		get_parent().add_child(newsword)
	#Finally, with 30% chance, do a tackle
	else:
		#Avoid the tackle when we are going to get out of the screen!
		if ((get_pos().x - ldist < 300 and not right) or (rdist - get_pos().x < 300 and right)): 
			elapsed_time = 100 #Elapsed time set so it will select another attack immediately
		else:
			atq = 40 #Tackle leads lot of damage, since it is the easier to avoid!
			#Bonus: with 50% chances, he will combo another attack! (reducing time for next attack)
			if (randf() < 0.5):
				atqtime = default_atqtime / 6.0
			else:
				atqtime = default_atqtime
			throwing_sword = 3 #Set marker
			change_anim("ataque1") #Put animation

#Tackle function
func body_atq(delta):
	var dir
	#Animation have some frames of preparation -gives chance to react
	if (get_node("anim").get_current_animation_pos() >= 0.4):
		#Select direction of tackle
		if (right):
			dir = Vector2(1.0, 0.0)
			get_node("hitbox").set_pos(Vector2(12,44))
		else:
			dir = Vector2(-1.0, 0.0)
			get_node("hitbox").set_pos(Vector2(-16,44))
		#Move it at high speed!
		set_pos(get_pos() + dir * 2.0 * speed * delta)
	#After the animation finishes, we are done
	if (elapsed_time > get_node("anim").get_current_animation_length()):
		change_anim("pose")
		throwing_sword = 0 #Reinit marker so we start from the beginning
		elapsed_time = 0.0

#The sword will activate this to say it has finished and king can go to recover it
func sword_finished():
	throwing_sword = 0
	go_recover_sword = true


func go_recover(delta):
	#Get the direction where the sword is -where I have to go to recover
	var dir
	if (right):
		dir = Vector2(1.0, 0.0)
	else:
		dir = Vector2(-1.0, 0.0)
	set_pos(get_pos() + dir * speed * delta) #Move in that direction
	#Once we get the sword, that was stopped at ldist/rdist, we try to get it
	if (get_pos().x <= ldist or get_pos().x >= rdist):
		newsword.queue_free() #Destroy sword object
		go_recover_sword = false
		taking_sword_out = true 
		vulnerable = true 
		elapsed_time = 0.0
		change_anim("try_take")

#Damage the boss only when it is not vulnerable
func damage(swatq):
	if (vulnerable and not is_damaged):
		life -= swatq
		is_damaged = true
		elapsed_time_d = 0.0
		#If not enough life, kill it
		if (life < 0):
			change_anim("death")

#It will ALWAYS deal damage, except when distracted taking the sword out
func can_deal_damage():
	return (not vulnerable)

#Now with variable attack
func get_atq():
	return atq

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		get_node("anim").play(newanim) #Change it!