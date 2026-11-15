extends Area2D

var velocidade = 1000.0
var alvo = Vector2.ZERO
var voando = true

func _ready():
	body_entered.connect(_ao_entrar_corpo)
	$AnimatedSprite2D.animation_finished.connect(_ao_terminar_animacao)
	$AnimatedSprite2D.play("voar")


func iniciar(origem, destino):
	global_position = origem
	var direcao = (destino - origem).normalized()
	alvo = destino + direcao * 500

func _process(delta):
	if not voando:
		return
	global_position = global_position.move_toward(alvo, velocidade * delta)
	if global_position == alvo:
		voando = false
		for corpo in get_overlapping_bodies():
			if corpo.name == "Jogador":
				corpo.voltar_ao_inicio()
				queue_free()
				return
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.play("cair")

func _ao_entrar_corpo(corpo):
	if voando and corpo.name == "Jogador":
		corpo.voltar_ao_inicio()
		queue_free()

func _ao_terminar_animacao():
	if $AnimatedSprite2D.animation == "cair":
		$AnimatedSprite2D.play("sumir")
	elif $AnimatedSprite2D.animation == "sumir":
		queue_free()
