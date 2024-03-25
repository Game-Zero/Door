extends CharacterBody2D

@onready var anim = $anim
var bIsRotatePause = false
var playerDirection
var eatenCallback

func _ready():
	anim.frame = 0
	rotate((randi() % 360) * 2 * PI / 360)
	pass

func _physics_process(delta):
	if !bIsRotatePause:
		rotate(delta * 2 * PI / 360 * 72)
	
func remove_self():
	if get_parent():
		get_parent().remove_child(self)
		
func start_being_eaten(direction: int, callback):
	bIsRotatePause = true
	eatenCallback = callback
	playerDirection = direction
	call_deferred("being_eaten")

func being_eaten():
	rotation = 0
	if playerDirection > 0:
		anim.scale *= Vector2(-1, 1)
	anim.play("big_fat_being_eaten")

func _anim_finish():
	eatenCallback.call()
	remove_self()
