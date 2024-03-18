extends CharacterBody2D

@onready var flip_anim = $flip_anim
@onready var rotate_anim = $rotate_anim

var id = 0

func _ready():
	flip_anim.stop()
	flip_anim.frame = 0
	rotate_anim.play("fat_rotating_" + str(id))
	pass

func _flip_anim_finish():
	id ^= 1
	rotate_anim.play("fat_rotating_" + str(id))
	pass

func _rotate_anim1_finish(anim_name: StringName):
	print("_rotate_anim_finish: " + anim_name)
	flip_anim.play("fat_fliping")
	pass
