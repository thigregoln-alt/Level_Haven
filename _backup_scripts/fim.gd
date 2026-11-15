extends Area2D

@export var proxima_cena = "res://cenas/fases/boss.tscn"
var usado = false

func _ready():
	body_entered.connect(_ao_entrar_corpo)

func _ao_entrar_corpo(corpo):
	if usado or corpo.name != "Jogador":
		return
	usado = true
	# o ourico para de andar (a mesma trava de quando cai no buraco)
	corpo.caindo = true
	corpo.get_node("AnimatedSprite2D").play("parado")

	# a nuvem do fim cresce ate cobrir a tela toda
	var nuvem = get_parent().get_node("NuvemFim")
	var centro = corpo.get_node("Camera2D").get_screen_center_position()
	nuvem.z_index = 50
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(nuvem, "global_position", centro, 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(nuvem, "scale", Vector2(5, 7), 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(get_parent().get_node("Musica"), "volume_db", -40.0, 1.4)
	tween.tween_property($Tela/Nuvem, "color:a", 1.0, 0.6).set_delay(0.9)
	await tween.finished
	get_tree().change_scene_to_file(proxima_cena)
