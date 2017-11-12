extends KinematicBody2D

#King controller: this function controls the King Skeleton
#The character can move around/fly using the arrows

var acel = Vector2(0.5, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(1.8, 1.3) #Maximum allowed speed
var brake = 0.1 #Allows smooth brake
var brakelim = brake*1.01 #Delete residual speed of brake
var right = true #Direction we are looking at
var input_x = false #We are not making any input in x

var jump_height = 100 #Height you can jump
var target_height = -1.0 #Where do I have to jump? 
var start_height #Height where jump started
var input_y = false  #We are not making any input in y

var atq1 = true #Controls which animation I use
var is_throwing = false #true when we are throwing the sword
var sword_destroy = false #To avoid destructing the sword just launched

var sword = preload("res://scenes/sword.tscn")

var lifepoints = 100 #Life of the King
var stun = 3.0
var elapsed_time = 0.0
var is_damaged = false

func _ready():
	start_height = get_pos().y #Initial start height
	set_fixed_process(true) #Start the fixed process

#Proceso fijo
func _fixed_process(delta):
	elapsed_time += delta
	#If the sword is not in the air, process King's input
	if (not is_throwing and not is_damaged):
		move_input(delta)
		if (is_colliding()):
			var n = get_collision_normal()
			#In case we are colliding with ground, get start height
			if (n == Vector2(0.0, -1.0)):
				start_height = get_pos().y
			vel = n.slide(vel)
			
		move(vel)
	elif (is_damaged):
		elapsed_time += delta #Start counter
		move(Vector2(-max_speed.x/5.0, 0.0))
		if (elapsed_time >= stun): #After sometime with no control
			is_damaged = false #Return control to King
			change_anim("idle") #Idle animation
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
	if (Input.is_action_pressed("ui_up")):
		input_y = true
		change_anim("float")
		#If we have not started a jump, then start one
		if (target_height == -1):
			#start_height = get_pos().y #Current height
			target_height = start_height - jump_height #Get where I want to jump
		#Once we have the target height, stop it
		elif (get_pos().y < target_height):
			vel.y = 0 
		#If we still did not reach it -continue up
		else:
			vel.y = -max_speed.y #Up with constant speed
	#Drop the button, then go down
	else:
		input_y = false
		vel.y += acel.y #Simulate gravity
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
	print("holi")
	is_damaged = true #Enter in damage state
	elapsed_time = 0.0 #Start counter
	change_anim("damage") #Damaged anim
	lifepoints -= points #Eliminate points
	
	#TODO: redraw HP 

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		get_node("anim").play(newanim) #Change it!

func _on_hitbox_body_enter( body ):
	#If we detect a collision with the sword,
	if (body.get_name() == "sword"):
		#Don't count the collision reported by creation of sword,
		if (!sword_destroy): 
			sword_destroy = true
		else: #but when it returns
			body.queue_free() #Delete the sword
			is_throwing = false #Stop throwing
			change_anim("idle") #Idle anim


func _on_hitbox_area_enter( area ):
	#Hitboxes are childrens, so take parent
	var parent
	parent = area.get_parent() 
	#If we detect a collision with the sword (which is itself an area),
	if (area.get_name() == "sword"):
		#Don't count the collision reported by creation of sword,
		if (!sword_destroy): 
			sword_destroy = true
		else: #but when it returns
			area.queue_free() #Delete the sword
			is_throwing = false #Stop throwing
			change_anim("idle") #Idle anim
	elif (parent.is_in_group("enemy") and not is_damaged): #Attacked by enemy
		#Do damage to the King depending on enemy atq
		if (parent.can_deal_damage()):
			damage(parent.get_atq()) 
