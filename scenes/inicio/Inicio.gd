# Inicio.gd
extends Control

@onready var panel_titulo: Control = $PanelTitulo # Ajusta los nombres de tus nodos
@onready var panel_tutorial_pag2: Control = $PanelTutorialPag2
@onready var panel_tutorial_pag3: Control = $PanelTutorialPag3
@onready var panel_tutorial_pag4: Control = $PanelTutorialPag4
@onready var panel_cuenta_regresiva: Control = $PanelCuentaRegresiva

@onready var button_empezar: TextureButton = $PanelTitulo/ButtonEmpezar
@onready var button_continuar_pag2: TextureButton = $PanelTutorialPag2/ButtonContinuarPag2
@onready var button_continuar_pag3: TextureButton = $PanelTutorialPag3/ButtonContinuarPag3
@onready var button_continuar_pag4: TextureButton = $PanelTutorialPag4/ButtonContinuarPag4

@onready var texture_rect_numero_conteo: TextureRect = $PanelCuentaRegresiva/TextureRectNumeroConteo
@onready var timer_conteo: Timer = $TimerConteo
@onready var animation_player: AnimationPlayer = $AnimationPlayer # Para animaciones de titileo

var countdown_value: int = 3
var current_tutorial_panel: Control # Para saber qué panel está activo

# Texturas para la cuenta regresiva
var textura_conteo_3 = preload("res://assets/graphics/conteo 3.png")
var textura_conteo_2 = preload("res://assets/graphics/conteo 2.png")
var textura_conteo_1 = preload("res://assets/graphics/conteo 1.png")
# Añade aquí preloads para las texturas de los botones y tutoriales si las cambias por código.
# ej. var textura_titulo = preload("res://assets/graphics/texto inicio del juego titila.png")

func _ready():
	# Configurar estado inicial de los paneles
	panel_titulo.visible = true
	panel_tutorial_pag2.visible = false
	panel_tutorial_pag3.visible = false
	panel_tutorial_pag4.visible = false
	panel_cuenta_regresiva.visible = false
	current_tutorial_panel = panel_titulo

	# Conectar señales de los botones (haz esto en el editor o aquí)
	button_empezar.pressed.connect(_on_button_empezar_pressed)
	button_continuar_pag2.pressed.connect(_on_button_continuar_pag2_pressed)
	button_continuar_pag3.pressed.connect(_on_button_continuar_pag3_pressed)
	button_continuar_pag4.pressed.connect(_on_button_continuar_pag4_pressed)

	timer_conteo.timeout.connect(_on_timer_conteo_timeout)

	# Iniciar animación de titileo del título (si la tienes)
	if animation_player.has_animation("titileo_titulo"):
		animation_player.play("titileo_titulo")

	# Asignar texturas si no se hizo en el editor (ejemplo)
	# $PanelTitulo/TextureRectTitulo.texture = textura_titulo
	# $PanelCuentaRegresiva/TextureRectTextoEmpezara.texture = load("res://assets/graphics/el juego empezara.png")


func switch_panel(new_panel: Control):
	if current_tutorial_panel:
		current_tutorial_panel.visible = false
	new_panel.visible = true
	current_tutorial_panel = new_panel

func _on_button_empezar_pressed():
	switch_panel(panel_tutorial_pag2)
	# Aquí podrías cargar la textura "vamos a jugar.png" si no está ya en el TextureRect
	# $PanelTutorialPag2/TextureRectTextoPag2.texture = load("res://assets/graphics/vamos a jugar.png")

func _on_button_continuar_pag2_pressed():
	switch_panel(panel_tutorial_pag3)
	# Cargar textura "usa la flecha.png" (derecha)

func _on_button_continuar_pag3_pressed():
	switch_panel(panel_tutorial_pag4)
	# Cargar textura "usa las flecha.png" (izquierda)

func _on_button_continuar_pag4_pressed():
	switch_panel(panel_cuenta_regresiva)
	start_countdown()

func start_countdown():
	countdown_value = 3
	update_countdown_display()
	timer_conteo.start(1.0) # Inicia el temporizador para que cuente cada segundo

func update_countdown_display():
	match countdown_value:
		3:
			texture_rect_numero_conteo.texture = textura_conteo_3
		2:
			texture_rect_numero_conteo.texture = textura_conteo_2
		1:
			texture_rect_numero_conteo.texture = textura_conteo_1
		0:
			# La pantalla de gameplay podría mostrar el 0, o transicionamos antes.
			# El PDF sugiere que la cuenta regresiva llega a 1, luego la pantalla de gameplay (Pág 9) muestra 00:00
			pass 

	# Ocultar "El juego empezará en..." cuando la cuenta es 0 o menos
	var texto_empezara = $PanelCuentaRegresiva/TextureRectTextoEmpezara
	if texto_empezara: # Chequeo de existencia
		texto_empezara.visible = countdown_value > 0 
	texture_rect_numero_conteo.visible = countdown_value > 0


func _on_timer_conteo_timeout():
	countdown_value -= 1
	update_countdown_display()

	if countdown_value < 0: # Después de mostrar "1" y esperar un segundo, el valor será -1
		timer_conteo.stop()
		GameManager.reset_game_state() # Reiniciar puntajes y contadores
		get_tree().change_scene_to_file("res://scenes/gameplay/Gameplay.tscn")
	else:
		timer_conteo.start(1.0) # Reinicia el temporizador para el siguiente segundo
