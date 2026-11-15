extends CharacterBody2D

var velocidade = 300.0
var velocidade_pulo = 420.0
var direcao_atual = "baixo"
var pulando = false
var posicao_inicial = Vector2.ZERO
var mortes = 0
var caindo = false
var escala_normal = Vector2.ONE

func _ready():
	posicao_inicial = global_position
	escala_normal = $AnimatedSprite2D.scale
	add_to_group("jogador")
	$Label.text = "mortes: " + str(mortes)
	$AnimatedSprite2D.animation_finished.connect(_ao_terminar_animacao)

func voltar_ao_inicio():
	$SomMorrer.play()
	mortes = mortes + 1
	$Label.text = "mortes: " + str(mortes)
	global_position = posicao_inicial
	velocity = Vector2.ZERO
	$Camera2D.reset_smoothing()

func cair_no_buraco():
	caindo = true
	pulando = false
	velocity = Vector2.ZERO
	# o ourico vai encolhendo ate sumir no buraco
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", Vector2.ZERO, 0.4)
	await tween.finished
	$AnimatedSprite2D.scale = escala_normal
	voltar_ao_inicio()
	caindo = false

func _ao_terminar_animacao():
	pulando = false

func _physics_process(delta):
	if caindo:
		return

	var direcao = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direcao * velocidade
	if pulando:
		velocity = direcao * velocidade_pulo
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept") and not pulando:
		pulando = true
		$AnimatedSprite2D.play("pular")

	if pulando:
		return

	if direcao.x > 0:
		direcao_atual = "direita"
	elif direcao.x < 0:
		direcao_atual = "esquerda"
	elif direcao.y > 0:
		direcao_atual = "baixo"
	elif direcao.y < 0:
		direcao_atual = "cima"

	if direcao == Vector2.ZERO:
		$AnimatedSprite2D.play("parado")
	else:
		$AnimatedSprite2D.play("andar_" + direcao_atual)
