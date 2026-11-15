extends AudioStreamPlayer

func _ready():
	# quando a musica acaba, toca de novo
	finished.connect(play)
