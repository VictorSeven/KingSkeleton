extends Sprite

var elapsed_time = 0.0 #Time counter
var wait_time = 0.4 #Wait until falls
var anim_time  #Time of the animation
var colgado_text #Texture of the hang 
var start = false #Start suicide

var atq = 30 #Damage points

func _ready():
	get_node("hitbox").add_to_group("enemy")
	#Configure the animation
	anim_time = get_node("anim").get_animation("suicide").get_length()
	colgado_text = load("res://graphics/enemies/ahorcado/colgado.png")


func _fixed_process(delta):
	#While I am waiting, let time pass
	if (not start):
		if (elapsed_time < wait_time):
			elapsed_time += delta
		else:
			start = true #Start falling
			elapsed_time = 0.0
			get_node("anim").play("suicide") #Suicide!
	#Commit suicide
	else:
		#Attack animation
		if (elapsed_time < anim_time):
			elapsed_time += delta
		#Change animation to loop of hang 
		else:
			set_texture(colgado_text) #Change texture
			set_hframes(4) #Set number of frames
			get_node("anim").play("colgado") #Set hung
			set_fixed_process(false) #Stop doing anything
			#Free non-useful nodes
			get_node("radar").queue_free()
			get_node("hitbox").queue_free()

#We can deal damage during the suicide stuff
func can_deal_damage():
	return (start and elapsed_time < anim_time)

func get_atq():
	return atq

#This suffers no damage
func damage():
	pass

#Activation of the fall when king is near
func _on_radar_area_enter( area ):
	if (area.is_in_group("king") and not start):
		get_node("player").play("ahorcado")
		set_fixed_process(true)
