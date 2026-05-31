# checkpoint.gd
extends Area3D

func _ready():
	# Подключаем сигнал (можно через редактор, но для уверенности — в коде)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Проверяем, что вошедшее тело — это игрок (можно по имени или классу)
	if body.name == "PlayerCharacter" or body is CharacterBody3D:
		GameManager.save_checkpoint(body.global_position)
		# Можно добавить визуальный/звуковой эффект активации
