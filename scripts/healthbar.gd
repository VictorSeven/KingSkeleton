extends Container


var target #Entity used to get health value

var max_health = 100
var current_health = 100

var size = Vector2()
var segments = 20
var segment_height = 0
var segment_width = 0

var spacing = 2

var filled_solid_color = Color(1, 0, 0)
var filled_line_color = Color(0, 0, 0)
var filled_line_width = 2

var empty_solid_color = Color(1, 0, 0)
var empty_line_color = Color(0.7, 0.7, 0.9)
var empty_line_width = 2

func _ready():
	size = get_node("Panel").get_size() 
	segment_height = size.height
	segment_width = size.width / segments
	
	if (get_tree().get_root().has_node("Node2D/king")):
		target = get_tree().get_root().get_node("Node2D/king")
	else:
		queue_free()


func _draw():
	draw_bar()


func draw_bar():
	current_health = target.get_health();
	var i = 0;
	var vertex1 = Vector2()
	var vertex2 = Vector2()
	var vertex3 = Vector2()
	var vertex4 = Vector2()
	var filled_segments = current_health * segments / max_health
	
	var offset = 138
	
	while(i < segments):
		var is_next_box_filled = (i < filled_segments)
		vertex1 = Vector2(offset+i * segment_width, 0)
		vertex2 = Vector2(offset+i * segment_width, segment_height)
		vertex3 = Vector2(offset+(i+1) * segment_width - spacing, segment_height) 
		vertex4 = Vector2(offset+(i+1) * segment_width - spacing, 0)
		
		if(is_next_box_filled):
			draw_box(vertex1, vertex2, vertex3, vertex4, filled_line_color, filled_line_width, true, filled_solid_color)
		else:
			draw_box(vertex1, vertex2, vertex3, vertex4, empty_line_color, empty_line_width, false)
			
		i += 1


func draw_box(v1, v2, v3, v4, line_color, border_width, filled, fill_color=filled_solid_color):
	if(filled): 
		draw_rect(Rect2(v1, Vector2(segment_width - spacing, segment_height)), fill_color)
	draw_line(v1, v2, line_color, border_width)
	draw_line(v2, v3, line_color, border_width)
	draw_line(v3, v4, line_color, border_width)
	draw_line(v4, v1, line_color, border_width)