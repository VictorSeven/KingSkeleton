extends Node2D

func _ready():
	get_node("Area2D").add_to_group("enemy")

func can_deal_damage():
	return true

#ULTRAKILL
func get_atq():
	return 100000000