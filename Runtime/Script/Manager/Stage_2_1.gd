extends Node2D
var bHasSurgeryDone: bool = false
var bCanStartGame: bool = false
var body = null

@onready var camera = $camera
@onready var tables = $tables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (self.bCanStartGame and Input.is_action_just_pressed("player_fire") and not self.bHasSurgeryDone):
		self.bHasSurgeryDone = true
		start_game()
	pass


func start_game() -> void:
	body.set_can_move(false)
	body.person_state = body.PersonState.Medium
	body.person_animation_state = body.PersonAnimationState.Lie
	body.set_global_position(Vector2(1280, 570))
	tables.global_position.x = camera.global_position.x - 960
	tables.visible = true
	tables.start_game()


func on_doll_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_entered] body.name: ", body.name)
	self.body = body
	self.bCanStartGame = true


func on_doll_body_exit(body: Node2D) -> void:
	print("[Stage_2_1][on_doll_body_exit] body.name: ", body.name)
	self.bCanStartGame = false
	pass


func on_door_body_entered(body: Node2D) -> void:
	print("[Stage_2_1][on_door_body_entered] body.name: ", body.name)
	self.body = body
