# Carita.gd
extends Sprite2D

# Señal que se emitirá cuando la carita desaparezca,
# llevando la ruta del nodo del círculo blanco original que debe reaparecer.
signal carita_desaparecida(original_spot_node_path: NodePath)

@onready var timer: Timer = $Timer
var _original_spot_node_path: NodePath # Para guardar la ruta del círculo que reemplazó

func _ready():
	# La textura ya debería estar asignada en el editor.
	# texture = load("res://assets/graphics/carita feliz.png")

	# Conectar la señal 'timeout' del Timer al método que manejará la desaparición.
	# Puedes hacerlo en el editor o por código:
	timer.timeout.connect(_on_timer_timeout)
	print("_ready::timer",timer)
	# Incrementar el contador de caritas que han aparecido en el juego.
	GameManager.increment_caritas_vistas()

# Esta función será llamada desde Gameplay.gd para configurar la carita.
func setup_carita(duration: float, original_spot_path: NodePath):
	print("setup_carita::timer",timer)

	_original_spot_node_path = original_spot_path
	timer.wait_time = duration
	timer.start()
	print("Carita.gd: Carita configurada para durar ", duration, "s en spot: ", original_spot_path)

func _on_timer_timeout():
	print("Carita.gd: Timer timeout, carita desapareciendo. Spot original:", _original_spot_node_path)
	# Emitir la señal antes de que la carita se elimine.
	if not _original_spot_node_path.is_empty(): # Asegurarse que hay una ruta válida
		carita_desaparecida.emit(_original_spot_node_path)
	else:
		print("Carita.gd: Error - _original_spot_node_path está vacío al desaparecer.")

	queue_free() # Eliminar la carita de la escena.
