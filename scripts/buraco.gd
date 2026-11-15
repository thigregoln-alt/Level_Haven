extends Area2D


func _ready():
	$Aberto.hide()


func _physics_process(delta):
	for corpo in get_overlapping_bodies():

		if corpo.name == "Jogador" and corpo.pulando == false and corpo.caindo == false:

			$Folhas.hide()
			$Aberto.show()

			corpo.cair_no_buraco()

			await get_tree().create_timer(1.5).timeout

			$Aberto.hide()
			$Folhas.show()
