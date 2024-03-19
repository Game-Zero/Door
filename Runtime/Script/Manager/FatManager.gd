extends CharacterBody2D

@onready var anim = $anim

var id = 0
var bIsRotatePause = false
var lastRotation = 1
var palyerDirection
var eatenCallback

func _ready():
	anim.animation = "fat_fliping_0"
	anim.frame = 0
	pass

func _physics_process(delta):
	if !bIsRotatePause:
		rotate(delta * 2 * PI / 360 * 72)
	
	var rotation = transform.get_rotation()
	var flag = rotation / absf(rotation)
	
	if rotation * lastRotation < 0:
		bIsRotatePause = true
		anim.play("fat_fliping_" + str(id))
		id ^= 1
  
	lastRotation = rotation
	pass

func remove_self():
	if get_parent():
		get_parent().remove_child(self)
		
func start_being_eaten(direction: int, callback):
	bIsRotatePause = true
	eatenCallback = callback
	palyerDirection = direction
	call_deferred("being_eaten")

func being_eaten():
	rotation = 0
	if palyerDirection > 0:
		anim.scale *= Vector2(-1, 1)
	anim.play("fat_being_eaten")


func _flip_anim_finish():
	if anim.animation.begins_with("fat_fliping"):	
		bIsRotatePause = false
	elif anim.animation == "fat_being_eaten":
		eatenCallback.call()
		remove_self()



