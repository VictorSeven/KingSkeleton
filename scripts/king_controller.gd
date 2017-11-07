extends KinematicBody2D

#King controller: this function controls the King Skeleton
#The character can move around/fly using the arrows

#TODO: draw something.

var acel = 1.0 #Acceleration
var vel = Vector2(0.0, 0.0) #Speed
var max_speed = 1.0 #Maximum allowed speed

func _ready():
	set_fixed_process(true) #Start the fixed process

#Proceso fijo
func _fixed_process(delta):
	set_pos(get_pos() + vel * delta)

#Controls the input system in an abstract way
func _input_event(viewport, event, shape_idx):
	
	if (event.is_action_pressed("left")):
		vel.x -= acel
	elif (event.is_action_pressed("right")):
		vel.x += acel
	elif (event.is_action_pressed("down")):
		vel.y += acel
	elif (event.is_action_pressed("up")):
		vel.y -= acel
	else:
		vel = Vector2(0.0, 0.0) #TODO: smooth brake
	
	#Use length squared because length includes a square root, which is slow!
	if (vel.length_squared() > max_speed * max_speed):
		vel = vel.normalized()
