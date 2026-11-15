extends Area2D

func _ready():
	$Aberto.hide()

func _physics_process(delta):
	for corpo in get_overlapping_bodies():
		if corpo.name == "Jogador" and not corpo.pulando and not corpo.caindo:
			# as folhas saem e o buraco aparece
			$Folhas.hide()
			$Aberto.show()
			corpo.cair_no_buraco()
			await get_tree().create_timer(1.5).timeout
			# o buraco fecha de novo com as folhas
			$Aberto.hide()
			$Folhas.show()
