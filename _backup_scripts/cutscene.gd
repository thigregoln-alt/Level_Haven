extends Control

func _ready():
	$VideoStreamPlayer.finished.connect(_ao_terminar_video)

func _ao_terminar_video():
	get_tree().change_scene_to_file("res://cenas/fases/fase1.tscn")
