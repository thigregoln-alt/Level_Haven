extends Control


func _ready():
	$VideoStreamPlayer.finished.connect(video_acabou)


func video_acabou():
	get_tree().change_scene_to_file("res://cenas/fases/fase1.tscn")
