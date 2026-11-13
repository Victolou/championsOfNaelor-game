class_name DeadState
extends State

func enter():
	print(entity.name, " ha muerto")
	entity.animated_sprite_2d.play("death")

#Sirve para bloquear las teclas
func handle_input(_event):
	pass
