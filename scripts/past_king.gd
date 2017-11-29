extends Node2D

var elapsed_time = 0.0
var elapsed_time_d = 0.0
var damagetime = 2.0
var atqtime = 3.0

var sword = load("res://scenes/past_king_sword.tscn")

var king #An instance of king

var life = 500 
var atq = 40
var speed = 50.0
var vulnerable = false
var is_damaged = false
var right = false

var throwing_sword = 0
var go_recover_sword = false
var taking_sword_out = false 


export var ldist = 400
export var rdist = 400

func _ready():
	randomize()
	king = get_tree().get_root().get_node("Node2D/king") #Get the king
	get_node("hitbox").add_to_group("hitbox")
	get_node("hitbox").add_to_group("enemy")
	set_fixed_process(true)

func _fixed_process(delta):
	if (king.is_in_boss()):
		check_look()
		elapsed_time += delta
		if (not vulnerable):
			if (not go_recover_sword and throwing_sword == 0):
				if (elapsed_time > atqtime):
					do_atq()
					elapsed_time = 0.0
			else:
				if (go_recover_sword):
					go_recover(delta)
				else:
					if (elapsed_time > get_node("anim").get_current_animation_length()):
						elapsed_time = 0.0
						if (throwing_sword != 1):
							change_anim("pose")
		else:
			if (is_damaged):
				get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time_d)))
				if (elapsed_time_d > damagetime):
					is_damaged = false
					elapsed_time_d = 0.0
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			if (elapsed_time > get_node("anim").get_current_animation_length()):
				if (taking_sword_out):
					taking_sword_out = false
					change_anim("take_sword")
					elapsed_time = 0.0
				else:
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
					elapsed_time = 0.0 
					vulnerable = false
					is_damaged = false 
					change_anim("pose")

func check_look():
	if (not vulnerable):
		if (king.get_pos().x > get_pos().x):
			right = true
		else:
			right = false
		get_node("Sprite").set_flip_h(not right)

func do_atq():
	var r = randf()
	
	var newsword = sword.instance()
	change_anim("ataque2")
	if (r < 0.01):
		throwing_sword = 2
		newsword.init_circular(right)
	else:
		throwing_sword = 1
		newsword.init_linear(right, ldist-get_pos().x, rdist-get_pos().x)
	add_child(newsword)

func sword_finished():
	throwing_sword = 0
	go_recover_sword = true

func go_recover(delta):
	var dir
	if (right):
		dir = Vector2(1.0, 0.0)
	else:
		dir = Vector2(-1.0, 0.0)
	set_pos(get_pos() + dir * speed * delta)
	if (get_pos().x <= ldist or get_pos().x >= rdist):
		go_recover_sword = false
		get_child(get_child_count() - 1).queue_free()
		taking_sword_out = true
		vulnerable = true
		elapsed_time = 0.0
		change_anim("try_take")

func damage(swatq):
	if (vulnerable and not is_damaged):
		life -= swatq
		is_damaged = true
		elapsed_time_d = 0.0

func can_deal_damage():
	return (not vulnerable)

func get_atq():
	return atq

func change_anim(newanim):
	#If the animation is new,
	if (newanim != get_node("anim").get_current_animation()):
		get_node("anim").play(newanim) #Change it!