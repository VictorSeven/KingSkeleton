extends Area2D

var king_pos #King's pos
var k = 20 #Elastic constant of oscillator 
var input_force = 600.0 #Force by user
var initial_vel = 1000.0 #Initial velocity
var vel 

var cycle = 0 #Cycle of sword movement
var lifetime = [1.0, 0.3, 1000] #Time to change behaviour
var elapsed_time = 0.0 #Counter

var atq = 10 #Damage dealed by sword

func _ready():
	add_to_group("sword")
	set_fixed_process(true)

func get_atq():
	return atq

#To pass king's pos as an argument 
func init_sword(pos, left):
	king_pos = pos #Vector2
	#Initial speed of sword based on King's direction
	if (left):
		vel = Vector2(-initial_vel, 0.0)
	else:
		vel = Vector2(initial_vel, 0.0)

#Integrate forces using Euler's scheme 
func _fixed_process(delta):
	#Each cycle has its time
	if (elapsed_time < lifetime[cycle]):
		elapsed_time += delta
		if (cycle == 0):
			#Elastic + brief player control
			vel += delta * (elastic_force() + move_input()) 
		elif (cycle == 1):
			vel = Vector2(0.0, 0.0) #Stop
		else:
			#Return with more speed
			vel += 5.0 * elastic_force() * delta
	else:
		#Update cycle
		cycle += 1
		elapsed_time = 0.0
	
	#Move without considering any obstacle
	set_pos(get_pos() + vel * delta)


#More distance to king, more force
func elastic_force():
	#Sword is child of king, so this pos is relative to king. 
	#get_pos is a vector from king to sword
	return -k * get_pos()



#Input by user makes a force over sword
func move_input():
	if (Input.is_action_pressed("ui_up")):
		return Vector2(0.0, -input_force)
	elif (Input.is_action_pressed("ui_down")):
		return Vector2(0.0, input_force)
	else:
		return Vector2(0.0, 0.0)


#Damage enemies
func _on_sword_area_enter( area ):
	if (area.is_in_group("hitbox")):
		if (area.get_parent().has_method("damage")):
			area.get_parent().damage(atq)
		else:
			area.damage(atq)
