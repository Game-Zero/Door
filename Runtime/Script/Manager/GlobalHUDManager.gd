extends CanvasLayer


func change_scene_to_file(scene_resource_path: String):
	get_tree().change_scene_to_file(scene_resource_path)


func reload_current_scene():
	get_tree().reload_current_scene()


func quit_scene():
	get_tree().quit()


# Called when the node enters the scene tree for the first time.
func _ready():
	print("[hud][current_scene.scene_file_path]", get_tree().current_scene.scene_file_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var paths: PackedStringArray = get_tree().current_scene.scene_file_path.split("/")
	var scene_file_name: String = paths[paths.size() - 1]

	if (scene_file_name.begins_with("Stage_0_0")):
		return

	if Input.is_action_pressed("ui_cancel"):
		get_node("esc").get_node("AnimationPlayer").play("pause_appear")
		get_node("esc").visible = true

	if Input.is_action_pressed("gm_reload_current_scene"):
		self.reload_current_scene()
