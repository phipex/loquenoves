# GameManager.gd
extends Node

var score: int = 0
var caritas_vistas_count: int = 0 # Caritas que realmente aparecieron
var caritas_reportadas_jugador: int = 0 # Caritas que el jugador dice haber visto
var game_time_seconds: int = 180 # 3 minutos de juego según PDF [cite: 13]

func reset_game_state():
	score = 0
	caritas_vistas_count = 0
	caritas_reportadas_jugador = 0

func increment_score():
	score += 1

func increment_caritas_vistas():
	caritas_vistas_count += 1

func get_results_message() -> String:
	if caritas_reportadas_jugador == caritas_vistas_count:
		return "¡Muy bien!\nAcertaste en el conteo\nde las caritas.\n\nFuiste de los pocos que logró superar\nla ceguera por inatención.\nUn fenómeno que ocurre cuando no\nnotamos algo visible porque estamos\nconcentrados en otra cosa, aunque\nnuestros ojos lo hayan visto." # Basado en PDF Páginas 18, 19 [cite: 19, 20, 21]
	else:
		return "Mmm…\nParece que no acertaste,\n¿Sabes porqué se da esto?\n\nComo estabas tan\nconcentrado en lograr pasar\nla mayor cantidad de\nbarreras, pasaste por alto las\ncaritas felices que aparecían\nen los laterales.\n\nEsto que acabas de\nexperimentar se llama\nCeguera por inatención.\nAnímate a jugar de nuevo\npara que puedas ver las\ncaritas." # Basado en PDF Páginas 15, 16, 17 [cite: 15, 16, 17, 18]
