extends Node2D

var distancia_para_comecar = 400.0
var tempo_entre_pinhas = 0.3
var alcance = 1000.0
var inicio_do_som = 3.0
@export var por_proximidade = false
@export var distancia_proximidade = 600.0
var ativa = false
var jogador = null
var cena_pinha = preload("res://cenas/pinha.tscn")

func _ready():
	$AnimatedSprite2D.play("escondida")
	$AnimatedSprite2D.animation_finished.connect(_ao_terminar_animacao)
	$AnimatedSprite2D.frame_changed.connect(_ao_mudar_frame)
	$Timer.wait_time = tempo_entre_pinhas
	$Timer.timeout.connect(_atirar)

func _process(delta):
	if jogador == null:
		jogador = get_tree().get_first_node_in_group("jogador")
		return

	var deve_aparecer = jogador.global_position.distance_to(jogador.posicao_inicial) > distancia_para_comecar
	if por_proximidade:
		deve_aparecer = jogador.global_position.distance_to(global_position) < distancia_proximidade

	if deve_aparecer and not ativa:
		ativa = true
		$AnimatedSprite2D.play("aparecer")
		$SomAparecer.play(inicio_do_som)
	elif not deve_aparecer and ativa:
		ativa = false
		$Timer.stop()
		$AnimatedSprite2D.play("escondida")

func _ao_terminar_animacao():
	var animacao = $AnimatedSprite2D.animation
	if animacao == "aparecer":
		$AnimatedSprite2D.play("parada")
		$Timer.start()
	elif animacao == "atirar":
		$AnimatedSprite2D.play("parada")

func _atirar():
	if global_position.distance_to(jogador.global_position) < alcance:
		$AnimatedSprite2D.play("atirar")

func _ao_mudar_frame():
	if $AnimatedSprite2D.animation == "atirar" and $AnimatedSprite2D.frame == 2:
		var pinha = cena_pinha.instantiate()
		get_parent().add_child(pinha)
		pinha.iniciar(global_position, jogador.get_node("CollisionShape2D").global_position)
