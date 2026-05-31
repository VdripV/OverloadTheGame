# game_manager.gd (Autoload)
extends Node

var last_checkpoint_position: Vector3 = Vector3.ZERO
var start_position: Vector3 = Vector3.ZERO   # начальная позиция уровня
var player: CharacterBody3D = null

func save_checkpoint(position: Vector3) -> void:
	last_checkpoint_position = position
	print("Checkpoint saved at: ", position)

func respawn_player() -> void:
	if not player:
		print("No player reference in GameManager")
		return
	
	# Если есть сохранённый чекпоинт – используем его, иначе – стартовую позицию
	if last_checkpoint_position != Vector3.ZERO:
		player.global_position = last_checkpoint_position
		print("Respawn at checkpoint")
	else:
		player.global_position = start_position
		print("Respawn at start position")
	
	player.velocity = Vector3.ZERO
