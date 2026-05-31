extends ColorRect   # или Control, если ваш контейнер не ColorRect

func _ready():
	# Гарантированно скрываем при старте
	visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("sprint"):   # когда зажали Shift
		visible = true
	elif event.is_action_released("sprint"): # когда отпустили Shift
		visible = false
