extends Control

var terminou = false

func _ready():
	$Fim.hide()
	$VideoStreamPlayer.finished.connect(_ao_terminar_video)

func _ao_terminar_video():
	# o video para no ultimo quadro e aparece o fim
	terminou = true
	$Fim.modulate.a = 0.0
	$Fim.show()
	var tween = create_tween()
	tween.tween_property($Fim, "modulate:a", 1.0, 1.0)

func _process(delta):
	# enter volta pro comeco do jogo
	if terminou and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://cenas/cutscene.tscn")
