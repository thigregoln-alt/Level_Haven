extends ColorRect

func _ready():
	# a tela comeca coberta pela nuvem e vai clareando
	color.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, 1.0)
