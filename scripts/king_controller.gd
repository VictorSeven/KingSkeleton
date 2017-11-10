extends KinematicBody2D

#King controller: this function controls the King Skeleton
#The character can move around/fly using the arrows

#TODO: draw something.

var acel = Vector2(0.5, 0.8) #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = Vector2(3.0, 1.5) #Maximum allowed speed
var brake = 0.1 #Allows smooth brake
var brakelim = brake*1.01 #Delete residual speed of brake

var jump_height = 60 #Height you can jump
var target_height = -1.0 #Where do I have to jump? 
var start_height #Height where jump started


func _ready():
	start_height = get_pos().y #Initial start height
	set_fixed_process(true) #Start the fixed process

#Proceso fijo
func _fixed_process(delta):
	move_input(delta)
	if (is_colliding()):
		var n = get_collision_normal()
		vel = n.slide(vel)
		
	move(vel)
	#set_pos(get_pos() + vel)


#Controls the input in an abstract way
func move_input(delta):
	#TODO: allow diagonal movement 
	if (Input.is_action_pressed("ui_right")):
		vel.x += acel.x
	elif (Input.is_action_pressed("ui_left")):
		vel.x -= acel.x 
	else:
		vel.x += - sign(vel.x) * brake #Smooth brake
		#Delete residual speed
		if (abs(vel.x) < brakelim):
			vel.x = 0.0
	
	#Init jump
	if (Input.is_action_pressed("ui_up")):
		#If we have not started a jump, then start one
		if (target_height == -1):
			start_height = get_pos().y #Current height
			target_height = start_height - jump_height #Get where I want to jump
		#Once we have the target height, stop it
		elif (get_pos().y < target_height):
			vel.y = 0 
		#If we still did not reach it -continue up
		else:
			vel.y = -max_speed.y #Up with constant speed
	#Drop the button, then go down
	else:
		vel.y += acel.y #Simulate gravity
		#Maximum speed of fall
		if (vel.y > max_speed.y):
			vel.y = max_speed.y
		#If we got at the save height or more, then our jump has finised.
		if (get_pos().y >= start_height):
			target_height = -1.0
	
	
	if (abs(vel.x) > max_speed.x):
		vel.x = sign(vel.x) * max_speed.x
