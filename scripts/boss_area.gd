extends Node2D

export var final_zoom = 0.75 #Final level of zoom (default is 0.5)
export var zoom_speed = 0.05 #Speed of change of zoom
export var offset = Vector2(200, 20) #Offset of camera lock

var camera #To get the camera

var started = false #Start of zoom out

func _ready():
	pass

#Do zoom out 
func _fixed_process(delta):
	zoom_out(delta)

#When we go into the player zone, lock the camera
func _on_radar_area_enter( area ):
	if (area.is_in_group("king") and not started):
		started = true #Start
		camera = area.get_parent().get_node("camera") #Get the camera
		lock_camera() #Lock it
		createWalls() #Generate walls

func createWalls():
	var pos = get_pos() #Get our pos
	#Get our size:
	var rect = get_node("radar/col").get_shape().get_extents()
	#MAke two big walls to trap character
	make_wall(Vector2(pos.x - offset.x, pos.y), Vector2(10, rect.height), Vector2(-1.0, 0.0))
	make_wall(Vector2(pos.x + rect.width, pos.y), Vector2(10, rect.height), Vector2(1.0, 0.0))

func make_wall(pos, extents, dir): 
	#Create new wall
	var wall = StaticBody2D.new()
	wall.set_pos(pos) #Put at posç
	#It can be passed to enter, but not to scape!
	wall.set_one_way_collision_direction(dir)
	wall.set_one_way_collision_max_depth(1.0)
	
	#Create the collision shape
	var shape = RectangleShape2D.new()
	shape.set_extents(extents)
	
	#Collision shape is editor helpr, add it to debug
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	
	#Add everything to scene
	wall.add_shape(shape)
	wall.add_child(collision)
	#Add this to parent so we can free this node after
	get_parent().add_child(wall)

#Lock the camera to boss area
func lock_camera():
	#Get the camera
	var rect = get_node("radar/col").get_shape().get_extents()
	#Set the limits to block it. Use offset to avoid problems
	camera.set_limit(MARGIN_LEFT, rect.x - offset.x)
	camera.set_limit(MARGIN_TOP, rect.y - offset.y)
	camera.set_limit(MARGIN_RIGHT, rect.x + rect.width)
	camera.set_limit(MARGIN_BOTTOM, rect.y + rect.height)

#Makes the zoom out
func zoom_out(delta):
	var zoom = camera.get_zoom() #Get the current level of zoom
	#Incrase the level of zoom
	if (zoom.x < final_zoom):
		camera.set_zoom(zoom + Vector2(1.0, 1.0) * zoom_speed * delta)
	else:
		#Once finished, the camera is locked,
		#zoom has changed and walls were created, so delete this node
		set_fixed_process(false)
		queue_free()

#If we enter the zoom,
func _on_boss_start_area_enter( area ):
	#and we are the king
	if (area.is_in_group("king")):
		started = true
		set_fixed_process(true) #Make the zoom
