extends KinematicBody2D

#King controller: this function controls the King Skeleton
#The character can move around/fly using the arrows

var healthbar
var path_to_healthbar = "Node2D/CanvasLayer_HUD/GridContainer/PlayerHUD/Healthbar"
var enemy_healthbar
var path_to_enemy_healthbar = "Node2D/CanvasLayer_HUD/GridContainer/EnemyHUD"
var dialog_hud
var path_to_dialog_hud = "Node2D/CanvasLayer_HUD/Dialog_HUD"

var gravity = Vector2(0, 500)
var acel = Vector2(20, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(150, 100) #Maximum allowed speed
var speedY = 100
var brake = 5.0 #Allows smooth brake
var brakelim = brake*1.01 #Delete residual speed of brake
var right = true #Direction we are looking at
var input_x = false #We are not making any input in x

var jump_height = 100 #Height you can jump
var target_height = -1.0 #Where do I have to jump? 
var start_height #Height where jump started
var input_y = false  #We are not making any input in y
var on_air_time = 0 #Time spent in the air since the last time floor was touched
var max_float_time =  1.0 #Maximum time to float around

var atq1 = true #Controls which animation I use
var is_throwing = false #true when we are throwing the sword
var sword_destroy = false #To avoid destructing the sword just launched


var sword = preload("res://scenes/sword.tscn")

var lifepoints = 100 #Life of the King
var stun = 3.0
var elapsed_time = 0.0
var is_damaged = false

var in_boss = false

func _ready():
	change_anim("idle")
	get_node("hitbox").add_to_group("king") #Set the hitbox as king
	start_height = get_pos().y #Initial start height
	healthbar = get_tree().get_root().get_node(path_to_healthbar).get_child(0)
	enemy_healthbar = get_tree().get_root().get_node(path_to_enemy_healthbar)
	dialog_hud = get_tree().get_root().get_node(path_to_dialog_hud)
	set_fixed_process(true) #Start the fixed process

#Proceso fijo
func _fixed_process(delta):
	elapsed_time += delta
	
	if (in_boss):
		enemy_healthbar.show()
	else:
		enemy_healthbar.hide()
	
	#If the sword is not in the air, process King's input
	if (not is_throwing and not is_damaged and not is_dialog_showing()):
		move_input(delta)
		
		# Integrate velocity into motion and move
		var motion = vel * delta
	
		if (is_colliding()):
			# You can check which tile was collision against with this
			# print(get_collider_metadata())
		
			
			var n = get_collision_normal()
			#In case we are colliding with ground, get start height
			if (n == Vector2(0.0, -1.0)):
				start_height = get_pos().y
				vel.y = 0.0
				on_air_time = 0 #In ground, reset air time counter
			#This avoids getting stuck over the walls
			#because it deletes the force pushing it that blocks y-vel
			elif(n == Vector2(1.0, 0.0)):
				if (vel.x < 0):
					vel.x = 0.0
			elif(n == Vector2(-1.0, 0.0)):
				if (vel.x > 0):
					vel.x = 0.0
		
		#set_pos(Vector2(get_pos().x, get_pos().y + sin(timer * frequency) * amplitude));
		#timer += 1;
		move(motion)
	elif (is_damaged):
		elapsed_time += delta #Start counter
		if (lifepoints > 0):
			#Make it go back depending on which side he is looking to
			if (right):
				move(Vector2(-delta*max_speed.x/5.0, 0.0))
			else:
				move(Vector2(delta*max_speed.x/5.0, 0.0))
			if (elapsed_time >= stun): #After sometime with no control
				is_damaged = false #Return control to King
				change_anim("idle") #Idle animation
		else:
			if (elapsed_time > 10.0):
				set_fixed_process(false)
				get_tree().set_pause(true)
				#TODO: lose game
	else:
		pass 
	



#Controls the input in an abstract way
func move_input(delta):
	#TODO: allow diagonal movement 
	if (Input.is_action_pressed("ui_right")):
		right = true #Looking to right
		input_x = true
		get_node("Sprite").set_flip_h(false)  #Looking to right 
		if (!input_y): #Check we are not floating!
			change_anim("walk") #Walk anim
		vel.x += acel.x
	elif (Input.is_action_pressed("ui_left")):
		right = false
		input_x = true
		get_node("Sprite").set_flip_h(true) #Looking to left
		if (!input_y): 
			change_anim("walk")
		vel.x -= acel.x 
	else:
		input_x = false
		vel.x += - sign(vel.x) * brake #Smooth brake
		#Delete residual speed
		if (abs(vel.x) < brakelim):
			vel.x = 0.0
	
	#Max x speed
	if (abs(vel.x) > max_speed.x):
		vel.x = sign(vel.x) * max_speed.x
	
	#Init jump
	if (Input.is_action_pressed("ui_up") and on_air_time < max_float_time): 
		input_y = true
		on_air_time += delta #Increase time floating
		#If we have not started a jump, then start one
		if (target_height == -1):
			#start_height = get_pos().y #Current height
			target_height = start_height - jump_height #Get where I want to jump
		#Once we have the target height, stop it
		elif (get_pos().y < target_height):
			change_anim("idle")
			vel.y = 0 
		#If we still did not reach it -continue up
		else:
			change_anim("float")
			vel.y = -speedY #Up with constant speed
	#Drop the button, then go down
	else:
		input_y = false
		vel += gravity*delta #Simulate gravity
		#Maximum speed of fall
		if (vel.y > max_speed.y):
			vel.y = max_speed.y
		#If we got at the save height or more, then our jump has finised.
		if (get_pos().y >= start_height):
			target_height = -1.0
	
	#If are doing nothing, then anim is idle
	if (not input_x and not input_y):
		change_anim("idle")
	
	#Do attack is we are not throwing sword
	if (Input.is_action_pressed("ui_accept") and !is_throwing):
		vel.x = 0.0 #Stop king
		get_node("player").play("throwsword")
		get_node("player").play("swordspin")
		var sword_world = sword.instance() #Instance new sword
		sword_world.init_sword(get_pos(), not right) #Init it
		add_child(sword_world) #Crate into world
		is_throwing = true #Set sword throw
		sword_destroy = false
		#Use one of our two anims
		if (atq1):
			change_anim("atq1_throw")
		else:
			change_anim("atq2_throw") 
		atq1 = not atq1 #Change animation for next

func damage(points):
	if (not is_damaged):
		get_node("player").play("damage")
		is_damaged = true #Enter in damage state
		elapsed_time = 0.0 #Start counter
		lifepoints -= points #Eliminate points
		healthbar.update()
		if (lifepoints <= 0):
			get_node("player").play("kingdeath")
			change_anim("death") #Kill it
		else: 
			change_anim("damage") #Damaged anim


func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		get_node("anim").play(newanim) #Change it!

func is_in_boss():
	return in_boss

func start_boss():
	in_boss = true
	
func get_health():
	return lifepoints

func is_dialog_showing():
	return dialog_hud.is_visible()

func _on_hitbox_body_enter( body ):
	if (Input.is_action_pressed("ui_accept")):
		if (body.is_in_group("npc")):
			body.show_dialog()
			
	#If we detect a collision with the sword,
	if (body.is_in_group("sword")):
		#Don't count the collision reported by creation of sword,
		if (!sword_destroy): 
			sword_destroy = true
		else: #but when it returns
			get_node("player").stop_all()
			get_node("player").play("getsword")
			body.queue_free() #Delete the sword
			is_throwing = false #Stop throwing
			change_anim("idle") #Idle anim


func _on_hitbox_area_enter( area ):
	#If we detect a collision with the sword (which is itself an area),
	if (area.is_in_group("sword")):
		#Don't count the collision reported by creation of sword,
		if (!sword_destroy): 
			sword_destroy = true
		else: #but when it returns
			get_node("player").stop_all()
			get_node("player").play("getsword")
			area.queue_free() #Delete the sword
			is_throwing = false #Stop throwing
			change_anim("idle") #Idle anim
	elif (area.is_in_group("enemy") and not is_damaged): #Attacked by enemy
		#Do damage to the King depending on enemy atq
		if (area.get_parent().can_deal_damage()):
			damage(area.get_parent().get_atq()) 


func _on_radar_area_enter( area ):
	if (area.is_in_group("king")):
		get_node("/root/global").goto_scene("res://scenes/Castle.tscn")
