extends Node2D


var tempo = 0.0
var velocidade = 520.0
var x_alvo = 470.0
var x_nasce = 1600.0

var linhas_y = [440, 500, 560, 620]

var setas = [
	preload("res://arte/boss/seta_0.png"),
	preload("res://arte/boss/seta_1.png"),
	preload("res://arte/boss/seta_2.png"),
	preload("res://arte/boss/seta_3.png")
]
var alvos = [
	preload("res://arte/boss/alvo_0.png"),
	preload("res://arte/boss/alvo_1.png"),
	preload("res://arte/boss/alvo_2.png"),
	preload("res://arte/boss/alvo_3.png")
]

var aceso = [0.0, 0.0, 0.0, 0.0]
var apertado = [0.0, 0.0, 0.0, 0.0]


func _process(delta):
	for i in range(4):
		if aceso[i] > 0:
			aceso[i] = aceso[i] - delta
		if apertado[i] > 0:
			apertado[i] = apertado[i] - delta


func apertar(direcao, acertou):
	apertado[direcao] = 0.1
	if acertou == true:
		aceso[direcao] = 0.18


func _draw():
	var boss = get_parent()

	for i in range(4):
		var centro = Vector2(x_alvo, linhas_y[i])

		if aceso[i] > 0:
			desenhar(setas[i], centro, 1.12, 0.0, 1.0)
		elif apertado[i] > 0:
			desenhar(alvos[i], centro, 0.88, 0.0, 1.0)
		else:
			desenhar(alvos[i], centro, 1.0, 0.0, 1.0)

	for n in range(boss.notas.size()):
		var nota = boss.notas[n]
		var tempo_da_nota = nota[0]
		var direcao_da_nota = nota[1]

		var x = x_alvo + (tempo_da_nota - tempo) * velocidade

		if x > x_nasce + 60:
			break

		if boss.estado[n] != "vindo":
			continue

		var transparencia = clamp((x_nasce + 60 - x) / 60.0, 0.0, 1.0)

		if x < x_alvo:
			transparencia = clamp(1.0 - (x_alvo - x) / 90.0, 0.0, 1.0)

		var giro = 0.05
		if n % 2 == 0:
			giro = -0.05

		var posicao = Vector2(x, linhas_y[direcao_da_nota])
		desenhar(setas[direcao_da_nota], posicao, 1.0, giro, transparencia)


func desenhar(textura, centro, tamanho, giro, transparencia):
	draw_set_transform(centro, giro, Vector2(tamanho, tamanho))
	draw_texture(textura, -textura.get_size() / 2, Color(1, 1, 1, transparencia))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
