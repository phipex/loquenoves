# Player.gd
extends CharacterBody2D

@onready var sprite_2d_bolita: Sprite2D = $Sprite2DBolita # Asegúrate que el nombre del nodo Sprite2D sea "Sprite2DBolita"

@export var speed: float = 400.0 # Velocidad de movimiento horizontal
var screen_size: Vector2 # Variable para guardar el tamaño de la pantalla

func _ready():
	screen_size = get_viewport_rect().size
	# La textura ya debería estar asignada en el editor, pero puedes forzarla aquí si es necesario:
	# sprite_2d_bolita.texture = load("res://assets/graphics/bolita.png")

	# Posición inicial (ej. centro horizontal, a media altura)
	# Esto puede ser manejado por la escena Gameplay al instanciar al jugador.
	# Si quieres que el jugador se posicione solo:
	# global_position.x = screen_size.x / 2
	# global_position.y = screen_size.y / 2 
	# (PDF Pag 9: "la bolita cae hasta la mitad de la pantalla")

func _physics_process(delta: float):
	var direction: float = 0.0
	if Input.is_action_pressed("ui_left"): # "ui_left" está mapeado a la flecha izquierda por defecto
		direction = -1.0
	if Input.is_action_pressed("ui_right"): # "ui_right" está mapeado a la flecha derecha por defecto
		direction = 1.0

	velocity.x = direction * speed
	move_and_slide() # Maneja el movimiento y las colisiones básicas

	# Mantener al jugador dentro de los límites horizontales de la pantalla
	var sprite_width_scaled = sprite_2d_bolita.get_rect().size.x * sprite_2d_bolita.scale.x
	global_position.x = clamp(global_position.x, sprite_width_scaled / 2.0, screen_size.x - sprite_width_scaled / 2.0)

func die():
	print("Player.gd: El jugador ha colisionado y debe morir.")
	# Aquí puedes añadir efectos visuales, sonidos, etc.
	# Por ahora, simplemente cambiamos a la pantalla final.
	# Ocultar al jugador para que no interactúe más
	hide() 
	# Desactivar colisiones para evitar múltiples llamadas a die()
	set_physics_process(false) 
	if get_node_or_null("CollisionShape2D"): # Chequeo por si acaso
		get_node("CollisionShape2D").disabled = true

	# Esperar un breve momento antes de cambiar de escena (opcional)
	# await get_tree().create_timer(0.5).timeout 
	get_tree().change_scene_to_file("res://scenes/final/Final.tscn")
