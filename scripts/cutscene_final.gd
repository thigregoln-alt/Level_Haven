extends Control


var terminou = false


func _ready():
	$Fim.hide()

	$VideoStreamPlayer.finished.connect(video_acabou)


func _process(delta):
	if terminou == true and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://cenas/cutscene.tscn")


func video_acabou():
	terminou = true

	$Fim.modulate.a = 0.0
	$Fim.show()

	var tween = create_tween()
	tween.tween_property($Fim, "modulate:a", 1.0, 1.0)
