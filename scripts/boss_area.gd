extends Node2D

export var final_zoom = 0.75 #Final level of zoom (default is 0.5)
export var final_move_up = 10 #Move camera up on zoom out
export var zoom_speed = 0.05 #Speed of change of zoom
export var offset = 0.0

export(NodePath) var left_wall
export(NodePath) var right_wall

var camera #To get the camera
var camera_limit #Original limit of the camera

var started = false #Entered area
var start_zoom = false #Start of the zoom

func _ready():
	left_wall = get_node(left_wall)
	right_wall = get_node(right_wall)

#Do zoom out 
func _fixed_process(delta):
	zoom_out(delta)

#When we go into the player zone, lock the camera
func _on_radar_area_enter( area ):
	if (area.is_in_group("king") and not started):
		started = true #Start
		camera = area.get_parent().get_node("camera") #Get the camera
		camera_limit = camera.get_limit(MARGIN_RIGHT) #Store old camera right limit
		lock_camera() #Lock it
		createWalls() #Generate walls

func createWalls():
	var pos = get_pos() #Get our pos
	#Get our size:
	#var rect = get_node("radar/col").get_shape().get_extents()
	#Make two big walls to trap character
	left_wall.set_collision_mask_bit(0, true)
	left_wall.set_layer_mask_bit(0, true)
	right_wall.set_collision_mask_bit(0, true)
	right_wall.set_layer_mask_bit(0, true)



#Lock the camera to boss area
func lock_camera():
	#Set the limits to block it. Use offset to avoid problems
	camera.set_limit(MARGIN_LEFT, left_wall.get_pos().x - offset)
	camera.set_limit(MARGIN_RIGHT, right_wall.get_pos().x + offset)
	pass

#Makes the zoom out
func zoom_out(delta):
	var zoom = camera.get_zoom() #Get the current level of zoom
	
	for no_move in get_tree().get_nodes_in_group("no_move"):
		no_move.set_motion_scale(Vector2(0.3,0.3))
	
	#Incrase the level of zoom
	if (zoom.x < final_zoom):
		camera.set_zoom(zoom + Vector2(1.0, 1.0) * zoom_speed * delta)
		camera.set_pos(camera.get_pos() - Vector2(0.0, delta*final_move_up))
	else:
		#Once finished, the camera is locked,
		#zoom has changed and walls were created, so delete this node
		set_fixed_process(false)
		queue_free()


#If we enter the zoom,
func _on_boss_start_area_enter( area ):
	#and we are the king
	if (area.is_in_group("king") and not start_zoom):
		get_tree().get_root().get_node("Node2D/musicplayer").set_stream(load("res://music/ost/finalboss.ogg"))
		get_tree().get_root().get_node("Node2D/musicplayer").play()
		start_zoom = true
		area.get_parent().start_boss()
		set_fixed_process(true) #Make the zoom
