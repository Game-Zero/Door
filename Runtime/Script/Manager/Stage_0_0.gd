extends Node2D


var arr: Array[Variant]  = [[0, 0], [0, 1], [1, 1], [2, 1], [3, 1], [3, 2], [4, 1]]
var b_loaded: Dictionary = {}
var loading_id: int = 0
@export var hud: CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	return # todo:zero 改成异步加载资源
	loading_id = 0
	var share_instance: Node = get_node("/root/SharedInstance")
	if (share_instance.shared_data_map.has("maps_size") and share_instance.shared_data_map["maps_size"] == arr.size()):
		return
	share_instance.shared_data_map["maps"] = {}
	share_instance.shared_data_map["maps_size"] = arr.size()
	load_scene(loading_id)
	pass # Replace with function body.


func load_scene(id) -> void:
	print("[SceneLoader] start load scene %d: '%s' ..." % [id, arr[id]])
	var stage = arr[id]
	var path: String = "res://Runtime/Scene/Stage_%d_%d.tscn" % stage
	print("[SceneLoader] start load: " + path)
	ResourceLoader.load_threaded_request(path)
	get_node("loading").visible = true
	get_node("press").visible = false
	get_node("person").visible = false


func start_game():
	hud.change_scene_to_file("res://Runtime/Scene/Stage_0_1.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return # todo:zero 改成异步加载资源
	if (b_loaded.size() == arr.size()):
		get_node("loading").visible = false
		get_node("person").visible = true
		get_node("press").visible = true
	else:
		var stage = arr[loading_id]
		var path: String = "res://Runtime/Scene/Stage_%d_%d.tscn" % stage
		var progress: Array[Variant] = []
		var status: int              = ResourceLoader.load_threaded_get_status(path, progress)
		if (status == ResourceLoader.THREAD_LOAD_LOADED and progress[0] == 1):
			print("[SceneLoader] load finish: " + path, ", progress: ", progress[0], ", status: ", status)
			b_loaded[path] = true
			var share_instance: Node = get_node("/root/SharedInstance")
			var maps = share_instance.shared_data_map["maps"]
			maps[path] = ResourceLoader.load_threaded_get(path)
			loading_id = loading_id + 1
			if (loading_id < arr.size()):
				load_scene(loading_id)


func open_operation():
	get_node("./HUD/options/AnimationPlayer").play("options_appear")
