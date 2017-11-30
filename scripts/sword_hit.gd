extends Sprite

func _ready():
	var r = randi() % 4 + 1 #Get random sword sound an play it
	print(r)
	get_node("player").play("sw" + str(r) )


func _on_anim_finished():
	queue_free()
