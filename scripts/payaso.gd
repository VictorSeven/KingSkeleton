extends Node2D

var king
var healthbar
var path_to_healthbar = "Node2D/CanvasLayer_HUD/GridContainer/EnemyHUD/Healthbar"

var deathtex = load("res://graphics/enemies/payaso/death.png")

var maxlife = 150 #MAximum amount of life
var life = maxlife
var knife_atq = 20 #Damage dealed by knives
var card_atq = 10 #Damage dealed by cards
var throwtime = 5.0 #Each 5 seconds, throw a knife
var cardtime = 1.5 #Each 1.5 a card falls
var damagetime = 0.5 #Time clown is invincible after hit
#Time counters:
var elapsed_time_knife = 0.0
var elapsed_time_card = 0.0
var elapsed_time_damage = 0.0
#State vars
var cards_used = false  #Used when life = maxlife/2
var is_damaged = false

#Load all children
var knife = load("res://scenes/payaso_knive.tscn")
var card = load("res://scenes/payaso_card.tscn")
#Load card textures to instantiate them
var cardAtex = load("res://graphics/enemies/payaso/cardAanim.png")
var cardBtex = load("res://graphics/enemies/payaso/cardBanim.png")

var zone = 200 #Clown will walk from init_x_pos - zone, init_x_pos + zone
var minx #Left position of screen to turn right
var maxx
var left = true #Are we walking to right?
var maxvel = 30.0 #Movement speed
var vel = 0.0

var risa_inicial = false

var time_laugh = 10.0
var elapsed_time_laugh = 0.0

func _ready():
	randomize() #RNG
	king = get_tree().get_root().get_node("Node2D/king") #Get the king
	healthbar = get_tree().get_root().get_node(path_to_healthbar)
	#Zone where we are going to walk
	minx = get_pos().x - zone
	maxx = get_pos().x + zone
	#Set the zone as hitbox
	get_node("hitbox").add_to_group("hitbox")
	set_fixed_process(true)

func _fixed_process(delta):
	if (king.is_in_boss()):
		if (not risa_inicial):
			healthbar.show() #Show the healthbar
			get_node("player").play("risa1")
			risa_inicial = true
		laugh(delta)
		#Move and throw things if we are not damaged
		if (not is_damaged):
			movement()
			throw_timer(delta)
			set_pos(get_pos() + Vector2(vel * delta, 0.0))
		else:
			elapsed_time_damage += delta #Time of damage
			if (life > 0):
				#Alpha modulation allows player to see it has hit the clown
				get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, sin(elapsed_time_damage)))
				#Reocover from hit
				if (elapsed_time_damage > damagetime):
					elapsed_time_damage = 0.0
					is_damaged = false
					get_node("Sprite").set_modulate(Color(1.0, 1.0, 1.0, 1.0))
			else:
				#If we are dead, stop process and delete after animation finishes
				if (elapsed_time_damage > get_node("anim").get_current_animation_length()):
					set_fixed_process(false)
					king.kill_boss()
					queue_free()


func movement():
	#Move
	if (left):
		vel = -maxvel
	else:
		vel = maxvel
	
	#Turn back when the position reaches minx or maxx
	if (get_pos().x < minx):
		left = false
	elif (get_pos().x > maxx):
		left = true

#Throw stuff to the player
func throw_timer(delta):
	#Time counter
	elapsed_time_knife += delta
	elapsed_time_card += delta
	#Knife
	if (elapsed_time_knife >= throwtime):
		elapsed_time_knife = 0.0
		throw_knife() 
	#Throws cards only when we activate them
	if (cards_used and elapsed_time_card >= cardtime):
		elapsed_time_card = 0.0
		throw_card()

#This instances a new knife pointing to the player
func throw_knife():
	var new_knife = knife.instance()
	new_knife.init(knife_atq, king.get_pos(), get_pos())
	add_child(new_knife)

#This throws a card generated in a random pos
func throw_card():
	var new_card = card.instance()
	var texture
	var r = randf() 
	#This selects red or black card
	if (r < 0.5):
		texture = cardAtex
	else:
		texture = cardBtex
	#Init a new card in a big zone around the clown
	new_card.init(texture, Vector2((randf() - 0.5) * 10.0 * zone, -200), card_atq) 
	add_child(new_card)

#Damage the clown
func damage(swatq):
	if (not is_damaged): #Avoid extra damage
		life -= swatq
		healthbar.update()
		is_damaged = true
		if (life > 0):
			throwtime = throwtime * 0.8 #Reduce the rate of knive throw!
			#Cool animation of cards using particle emitter
			if (life <= maxlife/2 and not cards_used):
				get_node("player").play("cartas")
				get_node("cards_start/card1_generator").set_emitting(true)
				get_node("cards_start/card2_generator").set_emitting(true)
				cards_used = true
		else:
			get_node("anim").play("death") #Kill clown

func get_health():
	return life

func laugh(delta):
	elapsed_time_laugh += delta
	if (elapsed_time_laugh > time_laugh):
		elapsed_time_laugh= 0.0
		#Randomly select a laugh SFX
		var r = randf()
		if (r < 0.33):
			get_node("player").play("risa2")
		elif(r < 0.66):
			get_node("player").play("risa3")
		else:
			get_node("player").play("risa4")
