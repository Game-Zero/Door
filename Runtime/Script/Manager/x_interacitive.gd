extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var b_can_multi_time_use: bool = false


var x_button: TextureButton
var normal_texture: Texture2D
var pressed_texture: Texture2D
var hover_texture: Texture2D

var b_has_pressed: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	print("[x_interactive][_ready] parent.get_path(): ", get_parent().get_path())
	assert(get_parent() is Area2D, "Error: x_interactive 节点只能挂在Area2D下, 现在被挂到了 '{0}' 下 !!!!".format([get_parent().get_path()]))
	var parent: Area2D = get_parent() as Area2D
	parent.body_entered.connect(self.on_body_entered)
	parent.body_exited.connect(self.on_body_exited)
	x_button = get_node("X_button")
	x_button.button_down.connect(self.on_button_down)
	x_button.button_up.connect(self.on_button_up)
	x_button.pressed.connect(self.on_button_pressed)
	animation_player.animation_finished.connect(self.on_aninimation_finished)
	normal_texture = x_button.texture_normal
	pressed_texture = x_button.texture_pressed
	hover_texture = x_button.texture_hover


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (self.visible and not self.has_pressed()):
		if (Input.is_action_just_pressed("player_fire")):
			x_button.texture_normal = x_button.texture_pressed
		elif (Input.is_action_just_released("player_fire")):
			self.set_pressed()


func has_pressed() -> bool:
	return self.b_has_pressed


func reset_pressed() -> void:
	if (not self.b_can_multi_time_use):
		self.b_has_pressed = false
	x_button.texture_pressed = pressed_texture
	x_button.texture_hover = hover_texture
	x_button.texture_normal = normal_texture


func set_pressed() -> void:
	if (not self.b_can_multi_time_use):
		self.b_has_pressed = true
		x_button.texture_pressed = normal_texture
		x_button.texture_hover = normal_texture
	x_button.texture_normal = normal_texture

	if (self.visible and not self.b_can_multi_time_use):
		animation_player.play("button_x_disappear")


func change_pressed(b_pressed: bool) -> void:
	if (b_pressed):
		self.set_pressed()
	else:
		self.reset_pressed()


func on_body_entered(body: Node2D):
	print("[x_interactive][on_body_entered] body.name: ", body.name)
	if (self.b_can_multi_time_use or not self.has_pressed()):
		animation_player.play("button_x_appear")
		self.visible = true


func on_body_exited(body: Node2D):
	print("[x_interactive][on_body_exited] body.name: ", body.name)
	x_button.texture_pressed = pressed_texture
	x_button.texture_hover = hover_texture
	x_button.texture_normal = normal_texture
	if (self.visible and not (animation_player.current_animation == "button_x_disappear" and animation_player.is_playing())):
		animation_player.play("button_x_disappear")


func on_button_down():
	if (self.b_can_multi_time_use or not self.has_pressed()):
		print("[x_interactive][on_button_down]")
		Input.action_press("player_fire")


func on_button_up():
	if (self.b_can_multi_time_use or not self.has_pressed()):
		print("[x_interactive][on_button_up]")
		Input.action_release("player_fire")
		self.set_pressed()


func on_button_pressed():
	if (self.b_can_multi_time_use or not self.has_pressed()):
		print("[x_interactive][on_button_pressed]")


func on_aninimation_finished(anim_name: String):
	if (anim_name == "button_x_disappear"):
		self.visible = false
