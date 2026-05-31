extends AnimatableBody3D

func _ready():
	var tween = create_tween()
	tween.set_loops()   # бесконечное повторение
	# Двигаемся из точки А в точку В за 1 секунду
	tween.tween_property(self, "global_position", Vector3(26.288, 4, -109.806), 2.0)
	# Потом обратно за 1 секунду
	tween.tween_property(self, "global_position", Vector3(26.288, 2.300, -109.806), 2.0)
