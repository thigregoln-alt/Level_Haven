extends Area2D


var velocidade = 1000.0
var alvo = Vector2.ZERO
var voando = true


func _ready():
	body_entered.connect(entrou_corpo)

	$AnimatedSprite2D.animation_finished.connect(acabou_animacao)

	$AnimatedSprite2D.play("voar")


func iniciar(origem, destino):
	global_position = origem

	var direcao = (destino - origem).normalized()

	alvo = destino + direcao * 500


func _process(delta):
	if voando == false:
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


func entrou_corpo(corpo):
	if voando == true and corpo.name == "Jogador":
		corpo.voltar_ao_inicio()
		queue_free()


func acabou_animacao():
	if $AnimatedSprite2D.animation == "cair":
		$AnimatedSprite2D.play("sumir")
	elif $AnimatedSprite2D.animation == "sumir":
		queue_free()
