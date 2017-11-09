extends KinematicBody2D

#King controller: this function controls the King Skeleton
#The character can move around/fly using the arrows

#TODO: draw something.

var acel = 15.0 #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var dir = Vector2(0.0, 0.0) #Which direction I have pressed
var max_speed = 3.0 #Maximum allowed speed
var sqbrake = 0.3 #Allows smooth brake

func _ready():
	set_fixed_process(true) #Start the fixed process

#Proceso fijo
func _fixed_process(delta):
	move_input(delta)
	set_pos(get_pos() + vel)

#Controls the input in an abstract way
func move_input(delta):
	#TODO: allow diagonal movement 
	if (Input.is_action_pressed("ui_right")):
		vel.x += acel * delta
	elif (Input.is_action_pressed("ui_left")):
		vel.x -= acel * delta
	elif (Input.is_action_pressed("ui_down")):
		vel.y += acel * delta
	elif (Input.is_action_pressed("ui_up")):
		vel.y -= acel * delta
	else:
		vel += -vel / acel #Smooth brake
		
		#Delete residual speed
		if (vel.length_squared() < sqbrake):
			vel = Vector2(0.0,0.0)
	
	if (vel.length_squared() > max_speed * max_speed):
		vel = vel.normalized() * max_speed
