extends Node2D


@export var por_proximidade = false
@export var distancia_proximidade = 600.0

var distancia_para_comecar = 400.0
var tempo_entre_pinhas = 0.3
var alcance = 1000.0
var inicio_do_som = 3.0

var ativa = false
var jogador = null
var cena_pinha = preload("res://cenas/pinha.tscn")


func _ready():
	$AnimatedSprite2D.play("escondida")

	$AnimatedSprite2D.animation_finished.connect(acabou_animacao)

	$AnimatedSprite2D.frame_changed.connect(mudou_frame)

	$Timer.wait_time = tempo_entre_pinhas
	$Timer.timeout.connect(atirar)


func _process(delta):
	if jogador == null:
		jogador = get_tree().get_first_node_in_group("jogador")
		return

	var aparecer = false

	if por_proximidade == true:
		var distancia = jogador.global_position.distance_to(global_position)
		if distancia < distancia_proximidade:
			aparecer = true
	else:
		var andou = jogador.global_position.distance_to(jogador.posicao_inicial)
		if andou > distancia_para_comecar:
			aparecer = true

	if aparecer == true and ativa == false:
		ativa = true
		$AnimatedSprite2D.play("aparecer")
		$SomAparecer.play(inicio_do_som)

	elif aparecer == false and ativa == true:
		ativa = false
		$Timer.stop()
		$AnimatedSprite2D.play("escondida")


func acabou_animacao():
	var animacao = $AnimatedSprite2D.animation

	if animacao == "aparecer":
		$AnimatedSprite2D.play("parada")
		$Timer.start()

	elif animacao == "atirar":
		$AnimatedSprite2D.play("parada")


func atirar():
	var distancia = global_position.distance_to(jogador.global_position)

	if distancia < alcance:
		$AnimatedSprite2D.play("atirar")


func mudou_frame():
	if $AnimatedSprite2D.animation == "atirar" and $AnimatedSprite2D.frame == 2:

		var pinha = cena_pinha.instantiate()

		get_parent().add_child(pinha)

		var alvo = jogador.get_node("CollisionShape2D").global_position
		pinha.iniciar(global_position, alvo)
