# Gameplay.gd
extends Node2D

@onready var texture_rect_fondo: TextureRect = $TextureRectFondo
@onready var player: CharacterBody2D = $Player # Asegúrate que el nodo Player se llame "Player"
@onready var node_obstaculos: Node2D = $NodeObstaculos
@onready var node_caritas: Node2D = $NodeCaritas

@onready var node_2d_lateral_izquierdo: Node2D = $Node2DLateralIzquierdo
@onready var node_2d_lateral_derecho: Node2D = $Node2DLateralDerecho
var carita_spawn_points: Array[Sprite2D] = [] # Array para todos los spots de caritas

@onready var timer_obstaculos: Timer = $TimerObstaculos
@onready var timer_caritas: Timer = $TimerCaritas
@onready var timer_juego: Timer = $TimerJuego

@onready var label_puntaje: Label = $CanvasLayerUI/HBoxContainerInfo/LabelPuntaje
@onready var label_tiempo: Label = $CanvasLayerUI/HBoxContainerInfo/LabelTiempo
# @onready var texture_rect_icono_reloj: TextureRect = $CanvasLayerUI/HBoxContainerInfo/TextureRectIconoReloj

# Precargar escenas para eficiencia
var obstacle_scene = preload("res://scenes/gameplay/Obstacle.tscn")
var carita_scene = preload("res://scenes/gameplay/Carita.tscn")

# Lista de texturas de obstáculos
var obstacle_textures_paths: Array[String] = [
	"res://assets/graphics/barra grande derecha.png",
	"res://assets/graphics/barra grande izquierda.png",
	"res://assets/graphics/barra pequeña derecha.png",
	"res://assets/graphics/barra pequeña izquierda.png",
	"res://assets/graphics/barra pequeña pequeña.png"
]
var loaded_obstacle_textures: Array[Texture2D] = []

var screen_size: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	#texture_rect_fondo.texture = load("res://assets/graphics/fondo.png")
	# texture_rect_icono_reloj.texture = load("res://assets/graphics/reloj de tiempo.png") # Si no está en editor

	# Cargar texturas de obstáculos una vez
	for path in obstacle_textures_paths:
		var tex = load(path) as Texture2D
		if tex:
			loaded_obstacle_textures.append(tex)
		else:
			print("Error cargando textura de obstáculo: ", path)

	# GameManager.reset_game_state() # Esto ya se hace en Inicio.gd antes de cambiar a esta escena

	# Poblar la lista de puntos de aparición de caritas
	for child in node_2d_lateral_izquierdo.get_children():
		if child is Sprite2D:
			carita_spawn_points.append(child)
			child.texture = load("res://assets/graphics/boton blanco.png") # Asegurar textura
	for child in node_2d_lateral_derecho.get_children():
		if child is Sprite2D:
			carita_spawn_points.append(child)
			child.texture = load("res://assets/graphics/boton blanco.png") # Asegurar textura

	print("Puntos de aparición de caritas encontrados: ", carita_spawn_points.size())

	# Conectar señales de los Timers (o hacerlo en el editor)
	timer_obstaculos.timeout.connect(_on_timer_obstaculos_timeout)
	timer_caritas.timeout.connect(_on_timer_caritas_timeout)
	timer_juego.timeout.connect(_on_timer_juego_timeout)

	# Configuración inicial de Timers (los valores de wait_time también se pueden poner en el editor)
	timer_obstaculos.wait_time = 2.5 # PDF Pag 10 sugiere después de 8s para las barras, ajustar
	timer_caritas.wait_time = randf_range(6.0, 10.0) # PDF Pag 10 "empiezan a aparecer las caritas aleatoriamente"

	# Iniciar timers si no tienen Autostart
	# timer_obstaculos.start()
	# timer_caritas.start()
	# timer_juego.start() # Este debería tener Autostart y OneShot

	label_puntaje.add_theme_color_override("font_color", Color.WHITE)
	label_tiempo.add_theme_color_override("font_color", Color.WHITE)
	label_tiempo.set("custom_minimum_size", Vector2(200, 40))
	label_puntaje.set("custom_minimum_size", Vector2(200, 40))

	update_ui()


func _physics_process(delta: float):
	update_ui() # Actualizar tiempo restante en cada frame

func _on_timer_obstaculos_timeout():
	if loaded_obstacle_textures.is_empty():
		print("No hay texturas de obstáculos cargadas.")
		return

	var new_obstacle = obstacle_scene.instantiate() as Area2D # Asegurar tipo

	# Asignar una textura de obstáculo aleatoria
	var random_texture: Texture2D = loaded_obstacle_textures.pick_random()
	var obstacle_sprite = new_obstacle.get_node_or_null("Sprite2DBarra") as Sprite2D
	if obstacle_sprite:
		obstacle_sprite.texture = random_texture
	else:
		print("Error: No se encontró Sprite2DBarra en la instancia de Obstacle.")
		new_obstacle.queue_free() # Limpiar si hay error
		return

	# Posicionar el obstáculo
	# El PDF no es claro sobre si las barras son de ancho completo o aparecen en posiciones X aleatorias.
	# Asumamos que aparecen desde abajo en una posición X aleatoria.
	var obstacle_width = random_texture.get_width() * obstacle_sprite.scale.x
	new_obstacle.global_position.x = randf_range(obstacle_width / 2.0, screen_size.x - obstacle_width / 2.0)
	new_obstacle.global_position.y = screen_size.y + random_texture.get_height() # Empezar justo debajo

	node_obstaculos.add_child(new_obstacle)

	# El script del obstáculo ya maneja la colisión con el jugador.
	# Incrementar puntaje (simplificado: por cada obstáculo generado)
	GameManager.increment_score()
	# update_ui() # Se llama en _physics_process

	# Reiniciar temporizador con un intervalo aleatorio
	timer_obstaculos.wait_time = randf_range(1.5, 3.5) # Ajustar frecuencia


func _on_timer_caritas_timeout():
	var available_spots = carita_spawn_points.filter(func(spot: Sprite2D): return spot.visible)
	print("Caritas Timeout. Spots disponibles: ", available_spots.size())

	if not available_spots.is_empty():
		var chosen_spot: Sprite2D = available_spots.pick_random()
		chosen_spot.visible = false # Ocultar el círculo blanco

		var new_carita_instance = carita_scene.instantiate()
		# Asegurarse que es del tipo correcto para llamar a setup_carita
		if new_carita_instance is Sprite2D and new_carita_instance.has_method("setup_carita"):
			var new_carita = new_carita_instance as Sprite2D # Cast para acceder a métodos específicos
			node_caritas.add_child(new_carita)			
			var carita_duration = randf_range(1.5, 3.0) # Cuánto tiempo la carita es visible
			new_carita.setup_carita(carita_duration, chosen_spot.get_path())

			new_carita.global_position = chosen_spot.global_position # Posicionar la carita
			new_carita.carita_desaparecida.connect(_on_carita_desaparecida) # Conectar señal


			print("Carita instanciada en spot: ", chosen_spot.get_path())
		else:
			print("Error: La instancia de carita no es válida o no tiene el método setup_carita.")
			chosen_spot.visible = true # Reestablecer el spot si la carita no se pudo crear
			if new_carita_instance: new_carita_instance.queue_free() # Limpiar instancia si se creó

	# Reiniciar temporizador con un intervalo aleatorio más largo
	timer_caritas.wait_time = randf_range(7.0, 12.0) # PDF Pag 10 "esporádicamente"


func _on_carita_desaparecida(original_spot_node_path: NodePath):
	print("Gameplay.gd: Señal carita_desaparecida recibida para spot: ", original_spot_node_path)
	var spot_node = get_node_or_null(original_spot_node_path) as Sprite2D
	if spot_node:
		spot_node.visible = true # Mostrar el círculo blanco de nuevo
		print("Spot restaurado: ", original_spot_node_path)
	else:
		print("Error: No se pudo encontrar el nodo del spot original para restaurar: ", original_spot_node_path)

func _on_timer_juego_timeout():
	print("Gameplay.gd: Tiempo de juego finalizado!")
	# Detener otros timers para que no sigan generando cosas
	timer_obstaculos.stop()
	timer_caritas.stop()
	if player and player.has_method("die"): # Forzar final si el jugador aún está activo
		player.set_physics_process(false) # Detener movimiento del jugador
		if player.get_node_or_null("CollisionShape2D"):
			player.get_node("CollisionShape2D").disabled = true
	get_tree().change_scene_to_file("res://scenes/final/Final.tscn")

func update_ui():
	label_puntaje.text = "Puntaje: %d" % GameManager.score # PDF Pag 11

	var remaining_time: float = timer_juego.time_left
	var minutes: int = int(remaining_time / 60)
	var seconds: int = int(remaining_time) % 60
	label_tiempo.text = "Tiempo: %02d:%02d" % [minutes, seconds] # PDF Pag 9, 11, 12
