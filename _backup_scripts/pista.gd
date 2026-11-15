extends Node2D

var tempo = 0.0
var velocidade = 520.0   # pixels por segundo
var x_alvo = 470.0
var x_nasce = 1600.0     # as setas vao aparecendo daqui
var linhas_y = [440, 500, 560, 620]
var setas = [preload("res://arte/boss/seta_0.png"), preload("res://arte/boss/seta_1.png"), preload("res://arte/boss/seta_2.png"), preload("res://arte/boss/seta_3.png")]
var alvos = [preload("res://arte/boss/alvo_0.png"), preload("res://arte/boss/alvo_1.png"), preload("res://arte/boss/alvo_2.png"), preload("res://arte/boss/alvo_3.png")]
var aceso = [0.0, 0.0, 0.0, 0.0]     # quanto tempo o alvo fica pintado depois de acertar
var apertado = [0.0, 0.0, 0.0, 0.0]  # quanto tempo o alvo fica afundado depois de apertar

func _process(delta):
	for i in range(4):
		aceso[i] = max(aceso[i] - delta, 0.0)
		apertado[i] = max(apertado[i] - delta, 0.0)

func apertar(direcao, acertou):
	apertado[direcao] = 0.1
	if acertou:
		aceso[direcao] = 0.18

func _draw():
	var boss = get_parent()

	# alvos riscados na terra
	for i in range(4):
		var centro = Vector2(x_alvo, linhas_y[i])
		if aceso[i] > 0:
			desenhar(setas[i], centro, 1.12, 0.0, 1.0)
		elif apertado[i] > 0:
			desenhar(alvos[i], centro, 0.88, 0.0, 1.0)
		else:
			desenhar(alvos[i], centro, 1.0, 0.0, 1.0)

	# setas vindo
	for n in range(boss.notas.size()):
		var nota = boss.notas[n]
		var x = x_alvo + (nota[0] - tempo) * velocidade
		if x > x_nasce + 60:
			break   # as notas estao em ordem, as outras ainda nao chegaram
		if boss.estado[n] != 0:
			continue
		# aparece aos poucos e some aos poucos depois que passa do alvo
		var transparencia = clamp((x_nasce + 60 - x) / 60.0, 0.0, 1.0)
		if x < x_alvo:
			transparencia = clamp(1.0 - (x_alvo - x) / 90.0, 0.0, 1.0)
		# cada seta fica um pouquinho torta, como feita a mao
		var giro = sin(n * 12.9898) * 0.08
		desenhar(setas[nota[1]], Vector2(x, linhas_y[nota[1]]), 1.0, giro, transparencia)

func desenhar(textura, centro, tamanho, giro, transparencia):
	draw_set_transform(centro, giro, Vector2(tamanho, tamanho))
	draw_texture(textura, -textura.get_size() / 2, Color(1, 1, 1, transparencia))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
