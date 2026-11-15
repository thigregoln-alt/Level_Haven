extends Node2D

var notas = preload("res://scripts/notas_boss.gd").NOTAS
var estado = []   # 0 = vindo, 1 = acertou, 2 = errou
var janela_acerto = 0.18
var teclas = ["ui_left", "ui_down", "ui_up", "ui_right"]

var vida_dino = 100.0
var vida_ourico = 100.0
# no turno do dino voce so se defende, no seu turno voce ataca
var dano_acerto_turno_dino = 0.8
var dano_acerto_turno_ourico = 1.65
var dano_erro_turno_dino = 3.5
var dano_erro_turno_ourico = 2.0

var turno_atual = ""
var acabou = false
var posicao_ourico = Vector2.ZERO
var tween_respirar = null

func _ready():
	for i in range(notas.size()):
		estado.append(0)
	posicao_ourico = $Ourico.position
	$Dino.animation_finished.connect(_ao_terminar_animacao_dino)
	$Ourico.animation_finished.connect(_ao_terminar_animacao_ourico)
	$Musica.finished.connect(_ao_terminar_musica)
	$BarraDino.value = vida_dino
	$BarraOurico.value = vida_ourico
	$TextoFim.hide()
	$Dino.play("parado")
	$Ourico.play("respirando")

	# o dino respira subindo e descendo devagar
	tween_respirar = create_tween().set_loops()
	tween_respirar.tween_property($Dino, "position:y", $Dino.position.y - 5, 0.9).set_trans(Tween.TRANS_SINE)
	tween_respirar.tween_property($Dino, "position:y", $Dino.position.y, 0.9).set_trans(Tween.TRANS_SINE)

	# a tela comeca coberta pela nuvem e vai clareando
	$Nuvem.color.a = 1.0
	var tween = create_tween()
	tween.tween_property($Nuvem, "color:a", 0.0, 1.0)
	$Musica.play()

func tempo_musica():
	return $Musica.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

func _process(delta):
	if acabou:
		return
	var tempo = tempo_musica()

	for direcao in range(4):
		if Input.is_action_just_pressed(teclas[direcao]):
			apertar(direcao, tempo)

	# notas que passaram do alvo sem ninguem acertar
	for i in range(notas.size()):
		if estado[i] == 0 and tempo - notas[i][0] > janela_acerto:
			estado[i] = 2
			errou(notas[i][2])

	ver_turno()
	$Pista.tempo = tempo
	$Pista.queue_redraw()

func apertar(direcao, tempo):
	# procura a nota dessa direcao mais perto do alvo
	var melhor = -1
	var menor_distancia = janela_acerto
	for i in range(notas.size()):
		if estado[i] == 0 and notas[i][1] == direcao:
			var distancia = abs(notas[i][0] - tempo)
			if distancia <= menor_distancia:
				menor_distancia = distancia
				melhor = i

	if melhor == -1:
		# apertou sem nota: o alvo so afunda, nao tira vida
		$Pista.apertar(direcao, false)
		return

	estado[melhor] = 1
	$Pista.apertar(direcao, true)
	acertou(notas[melhor][2])

func acertou(turno):
	if turno == "dino":
		vida_dino -= dano_acerto_turno_dino
	else:
		vida_dino -= dano_acerto_turno_ourico
		# no seu turno o dino sente cada acerto
		$Dino.play("dano")
	$Ourico.play("tocando")
	atualizar_barras()
	if vida_dino <= 0:
		vencer()

func errou(turno):
	if acabou:
		return
	if turno == "dino":
		vida_ourico -= dano_erro_turno_dino
	else:
		vida_ourico -= dano_erro_turno_ourico
	$Ourico.play("susto")
	# o ourico treme um pouquinho
	var tween = create_tween()
	tween.tween_property($Ourico, "position:x", posicao_ourico.x + 7, 0.04)
	tween.tween_property($Ourico, "position:x", posicao_ourico.x - 7, 0.06)
	tween.tween_property($Ourico, "position:x", posicao_ourico.x, 0.04)
	atualizar_barras()
	if vida_ourico <= 0:
		perder()

func atualizar_barras():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($BarraDino, "value", vida_dino, 0.15)
	tween.tween_property($BarraOurico, "value", vida_ourico, 0.15)

func ver_turno():
	# o turno e o da proxima nota que ainda vai chegar
	for i in range(notas.size()):
		if estado[i] == 0:
			if notas[i][2] != turno_atual:
				trocar_turno(notas[i][2])
			return

func trocar_turno(turno):
	turno_atual = turno
	if turno == "dino":
		$TextoVez.text = "vez do dino"
		$Dino.play("tocando")
	else:
		$TextoVez.text = "sua vez!"
		$Dino.play("parado")
	# o texto da um pulinho quando troca
	$TextoVez.scale = Vector2(1.3, 1.3)
	var tween = create_tween()
	tween.tween_property($TextoVez, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

func _ao_terminar_animacao_dino():
	if acabou:
		return
	if $Dino.animation == "dano":
		if turno_atual == "dino":
			$Dino.play("tocando")
		else:
			$Dino.play("parado")

func _ao_terminar_animacao_ourico():
	if acabou:
		return
	$Ourico.play("respirando")

func _ao_terminar_musica():
	if acabou:
		return
	# acabou a musica e ninguem zerou: quem tiver mais vida ganha
	if vida_ourico >= vida_dino:
		vencer()
	else:
		perder()

func vencer():
	acabou = true
	tween_respirar.kill()
	$Dino.play("dano")
	# o dino cai pra tras e some, a musica vai baixando
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Musica, "volume_db", -40.0, 2.5)
	tween.tween_property($Pista, "modulate:a", 0.0, 0.5)
	tween.tween_property($TextoVez, "modulate:a", 0.0, 0.5)
	tween.tween_property($Dino, "rotation", -0.35, 1.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Dino, "position:y", $Dino.position.y + 25, 1.2)
	tween.tween_property($Dino, "modulate:a", 0.0, 1.4).set_delay(0.4)
	await tween.finished

	$TextoFim.text = "vitória!"
	$TextoFim.show()
	$Ourico.play("tocando")
	await get_tree().create_timer(1.5).timeout

	var tween_nuvem = create_tween()
	tween_nuvem.tween_property($Nuvem, "color:a", 1.0, 0.8)
	await tween_nuvem.finished
	get_tree().change_scene_to_file("res://cenas/cutscene_final.tscn")

func perder():
	acabou = true
	# a musica desacelera, como um radio sem pilha
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Musica, "pitch_scale", 0.4, 1.2)
	tween.tween_property($Musica, "volume_db", -30.0, 1.2)
	tween.tween_property($Pista, "modulate:a", 0.0, 0.6)
	tween.tween_property($TextoVez, "modulate:a", 0.0, 0.6)
	$Dino.play("tocando")
	$Ourico.play("susto")
	$TextoFim.text = "tenta de novo..."
	$TextoFim.show()
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene()
