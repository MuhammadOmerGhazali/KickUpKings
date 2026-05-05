extends Node
class_name UIManager

signal retry_pressed

@export var start_menu_ui : Control 
@export var level_ui : Control
@export var game_over_ui : Control
@export var shop_ui : Control
@export var wardrobe_ui : Control
@export var leaderboard_ui : Control

enum Menu { START, LEVEL, GAME_OVER, SHOP, WARDROBE, LEADERBOARD }

@onready var all_menus : Array[Control] = [
	start_menu_ui, level_ui, game_over_ui, 
	shop_ui, wardrobe_ui, leaderboard_ui
]

func _ready() -> void:
	$"../UI/GameOver".retry_clicked.connect(_on_retry_button_clicked)
	change_menu(Menu.START)
	pass

func change_menu(target: Menu) -> void:
	for menu in all_menus:
		if menu: menu.visible = false
	
	match target:
		Menu.START: start_menu_ui.visible = true
		Menu.LEVEL: level_ui.visible = true
		Menu.GAME_OVER: game_over_ui.visible = true
		Menu.SHOP: shop_ui.visible = true
		Menu.WARDROBE: wardrobe_ui.visible = true
		Menu.LEADERBOARD: leaderboard_ui.visible = true


func _on_play_button_pressed() -> void:
	$"../CameraManager".goto_level()
	change_menu(Menu.LEVEL)
func _on_leader_board_button_pressed() -> void:
	change_menu(Menu.LEADERBOARD)
func _on_wardrobe_button_pressed() -> void:
	$"../CameraManager".goto_player()
	change_menu(Menu.WARDROBE)
func _on_shop_button_pressed() -> void:
	change_menu(Menu.SHOP)
func _on_back_btn_pressed() -> void:
	change_menu(Menu.START)


func changeScore(new_score:int):
	$"../UI/Level".increase_score(new_score)
func updateGameOver(final_score : int):
	$"../UI/GameOver/ManuBack/FinalScoreLabel".text = str(final_score)


func _on_retry_button_clicked():
	retry_pressed.emit()
