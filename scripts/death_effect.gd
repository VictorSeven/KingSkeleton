extends Sprite


func _ready():
	pass

#After playing, free the parent node that invoked this
func _on_AnimationPlayer_finished():
	get_parent().queue_free()
