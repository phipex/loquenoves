# Obstacle.gd
extends Area2D

# Exportar la variable permite ajustarla desde el editor o al instanciar.
@export var speed: float = 200.0 # Velocidad con la que sube el obstáculo

@onready var sprite_2d_barra: Sprite2D = $Sprite2DBarra
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D # Si necesitas referenciarlo
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	# Conectar la señal 'body_entered' de este Area2D a un método.
	# Esto se puede hacer en el editor:
	# 1. Selecciona el nodo Obstacle (Area2D).
	# 2. Ve a la pestaña "Nodo" (junto al Inspector).
	# 3. En la sección "Señales", haz doble clic en "body_entered(body: Node2D)".
	# 4. Se abrirá una ventana. Selecciona el nodo Obstacle (él mismo) y asegúrate
	#    que el "Método Receptor" sea "_on_body_entered" (o el nombre que prefieras).
	# 5. Haz clic en "Conectar".
	# O por código (como se muestra abajo, elige uno u otro método):
	# body_entered.connect(_on_body_entered) # Ya no es necesario si se conecta en el editor

	# Conectar la señal 'screen_exited' del Notifier para auto-eliminar el obstáculo.
	# Hazlo en el editor o por código:
	visible_on_screen_notifier_2d.screen_exited.connect(queue_free)
	# queue_free() es un método incorporado que elimina el nodo de la escena.

func _physics_process(delta: float):
	# Mover el obstáculo hacia arriba (disminuyendo su coordenada Y)
	global_position.y -= speed * delta

# Este método se llamará cuando otro cuerpo (con CollisionShape) entre en este Area2D.
func _on_body_entered(body: Node2D):
	# Verificar si el cuerpo que entró es el jugador.
	# El jugador debe estar en el grupo "player".
	if body.is_in_group("player"):
		# Llamar a una función en el script del jugador para manejar la "muerte" o colisión.
		if body.has_method("die"):
			body.die()

		# Opcional: El obstáculo también puede destruirse al colisionar con el jugador.
		# queue_free()
