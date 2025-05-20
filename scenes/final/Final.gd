# Final.gd
extends Control

@onready var panel_pregunta: Control = $VBoxContainerPrincipal/PanelPregunta
@onready var panel_resultado: Control = $VBoxContainerPrincipal/PanelResultado

@onready var label_numero_reportado: Label = $VBoxContainerPrincipal/PanelPregunta/HBoxConteoNumeros/LabelNumeroReportado
@onready var button_menos: TextureButton = $VBoxContainerPrincipal/PanelPregunta/HBoxConteoNumeros/ButtonMenos
@onready var button_mas: TextureButton = $VBoxContainerPrincipal/PanelPregunta/HBoxConteoNumeros/ButtonMas
@onready var button_continuar_quiz: TextureButton = $VBoxContainerPrincipal/PanelPregunta/ButtonContinuarQuiz

# Asegúrate que las rutas a estos TextureRects sean correctas según tu estructura de nodos
@onready var texture_rect_mensaje_resultado1: TextureRect = $VBoxContainerPrincipal/PanelResultado/TextureRectMensajeResultado1
@onready var texture_rect_mensaje_resultado2: TextureRect = $VBoxContainerPrincipal/PanelResultado/TextureRectMensajeResultado2
@onready var texture_rect_mensaje_resultado3: TextureRect = $VBoxContainerPrincipal/PanelResultado/TextureRectMensajeResultado3
@onready var button_reiniciar: TextureButton = $VBoxContainerPrincipal/PanelResultado/ButtonReiniciar

@onready var timer_mensajes: Timer = $TimerMensajes
# @onready var animation_player: AnimationPlayer = $AnimationPlayer # Si tienes animaciones

var w_izq: Shortcut = preload("res://W-izq.tres")
var p_centro: Shortcut = preload("res://P-centro.tres")
var siete_der: Shortcut = preload("res://7-der.tres")

# Preload de texturas para los mensajes de resultado
var tex_mmm_no_acertaste = preload("res://assets/graphics/mmm parece que no acertaste.png")
var tex_como_estabas_tan = preload("res://assets/graphics/como estabas tan.png")
var tex_esto_que_acabas = preload("res://assets/graphics/esto que acabas de.png")
var tex_muy_bien = preload("res://assets/graphics/muy bien.png")
var tex_fuiste_de_los_pocos = preload("res://assets/graphics/fuiste de los pocos.png")
# Preload para el botón de reiniciar si cambia su textura/texto
# var tex_btn_anim_jugar_nuevo = preload("res://assets/graphics/...")
# var tex_btn_jugar_nuevo = preload("res://assets/graphics/...")


var caritas_reportadas_temp: int = 0
var current_message_step: int = 0
var is_correct_answer: bool = false

func _ready():
	panel_pregunta.visible = true
	panel_resultado.visible = false
	texture_rect_mensaje_resultado1.visible = false # Ocultar todos los mensajes de resultado al inicio
	texture_rect_mensaje_resultado2.visible = false
	texture_rect_mensaje_resultado3.visible = false
	button_reiniciar.visible = false

	# Conectar señales
	button_menos.pressed.connect(_on_button_menos_pressed)
	button_menos.shortcut = w_izq
	
	button_mas.pressed.connect(_on_button_mas_pressed)
	button_mas.shortcut = siete_der
	
	button_continuar_quiz.pressed.connect(_on_button_continuar_quiz_pressed)
	button_continuar_quiz.shortcut = p_centro
	
	button_reiniciar.pressed.connect(_on_button_reiniciar_pressed)
	button_reiniciar.shortcut = p_centro
	timer_mensajes.timeout.connect(_on_timer_mensajes_timeout)

	update_caritas_reportadas_display()

	# Iniciar animación del botón continuar si existe
	# if animation_player.has_animation("titileo_continuar_quiz"):
	# 	animation_player.play("titileo_continuar_quiz")

	# Asignar texturas iniciales si es necesario (ej. para LabelPregunta o TextureRectBarraConteo)
	# $VBoxContainerPrincipal/PanelPregunta/LabelPregunta.text = "¿Pudiste ver cuántas caritas...?"
	# $VBoxContainerPrincipal/PanelPregunta/TextureRectBarraConteo.texture = load("res://assets/graphics/barra contadora de caritas.png")


func _on_button_menos_pressed():
	if caritas_reportadas_temp > 0:
		caritas_reportadas_temp -= 1
		update_caritas_reportadas_display()

func _on_button_mas_pressed():
	caritas_reportadas_temp += 1 # Considera un límite superior si es necesario
	update_caritas_reportadas_display()

func update_caritas_reportadas_display():
	label_numero_reportado.text = str(caritas_reportadas_temp)

func _on_button_continuar_quiz_pressed():
	GameManager.caritas_reportadas_jugador = caritas_reportadas_temp

	panel_pregunta.visible = false
	panel_resultado.visible = true

	is_correct_answer = (GameManager.caritas_reportadas_jugador == GameManager.caritas_vistas_count)
	print("Caritas reportadas:", GameManager.caritas_reportadas_jugador, "Caritas reales:", GameManager.caritas_vistas_count, "Correcto:", is_correct_answer)
	current_message_step = 0
	show_next_result_message()

func show_next_result_message():
	# Ocultar todos los mensajes antes de mostrar el siguiente
	texture_rect_mensaje_resultado1.visible = false
	texture_rect_mensaje_resultado2.visible = false
	texture_rect_mensaje_resultado3.visible = false
	button_reiniciar.visible = false

	var should_continue_to_next_message: bool = true
	var delay_for_next: float = 3.0 # PDF Páginas 15-19: "espera 3 segundos"

	if is_correct_answer:
		match current_message_step:
			0: # Primer mensaje de acierto
				texture_rect_mensaje_resultado1.texture = tex_muy_bien
				texture_rect_mensaje_resultado1.visible = true
			1: # Segundo mensaje de acierto
				texture_rect_mensaje_resultado2.texture = tex_fuiste_de_los_pocos
				texture_rect_mensaje_resultado2.visible = true
				should_continue_to_next_message = false # Fin de mensajes de acierto
			_:
				should_continue_to_next_message = false 
	else: # No acertó
		match current_message_step:
			0: # Primer mensaje de error
				texture_rect_mensaje_resultado1.texture = tex_mmm_no_acertaste
				texture_rect_mensaje_resultado1.visible = true
			1: # Segundo mensaje de error
				texture_rect_mensaje_resultado2.texture = tex_como_estabas_tan
				texture_rect_mensaje_resultado2.visible = true
			2: # Tercer mensaje de error
				texture_rect_mensaje_resultado3.texture = tex_esto_que_acabas
				texture_rect_mensaje_resultado3.visible = true
				should_continue_to_next_message = false # Fin de mensajes de error
			_:
				should_continue_to_next_message = false

	if should_continue_to_next_message:
		current_message_step += 1
		timer_mensajes.start(delay_for_next)
	else:
		# Ya no hay más mensajes, mostrar botón de reiniciar
		button_reiniciar.visible = true
		var label_reiniciar = button_reiniciar.get_node_or_null("Label") as Label # Si el texto está en un Label hijo
		if is_correct_answer:
			if label_reiniciar: label_reiniciar.text = "Jugar de Nuevo" # PDF Pag 19
			# button_reiniciar.texture_normal = tex_btn_jugar_nuevo # Si cambias la textura del botón
		else:
			if label_reiniciar: label_reiniciar.text = "Anímate a jugar de nuevo" # PDF Pag 17
			# button_reiniciar.texture_normal = tex_btn_anim_jugar_nuevo

func _on_timer_mensajes_timeout():
	show_next_result_message()

func _on_button_reiniciar_pressed():
	# GameManager.reset_game_state() # Ya se resetea en Inicio.gd
	get_tree().change_scene_to_file("res://scenes/inicio/Inicio.tscn")
