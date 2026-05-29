extends Node
class_name UIManager

signal retry_pressed
signal continue_pressed
signal menu_pressed

@export var start_menu_ui : Control 
@export var level_ui : Control
@export var game_over_ui :GameOverUi
@export var shop_ui : Control
@export var wardrobe_ui : Control
@export var leaderboard_ui : Control

enum Menu { START, LEVEL, GAME_OVER, SHOP, WARDROBE, LEADERBOARD }

@onready var all_menus : Array[Control] = [
	start_menu_ui, level_ui, game_over_ui, 
	shop_ui, wardrobe_ui, leaderboard_ui
]

func _ready() -> void:
	game_over_ui.retry_button_clicked.connect(_on_retry_button_clicked)
	game_over_ui.menu_button_pressed.connect(_on_menu_button_clicked)
	game_over_ui.continue_button_pressed.connect(_on_contine_button_clicked)
	
	change_menu(Menu.START)
	if DataManager.get_player_name() == "":
		$"../UI/StartMenu/Name".visible = true
	else :
		$"../UI/StartMenu/Name".visible = false
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
	$"../AudioManager".play_click()
	change_menu(Menu.LEVEL)
func _on_leader_board_button_pressed() -> void:
	change_menu(Menu.LEADERBOARD)
	$"../AudioManager".play_click()
func _on_wardrobe_button_pressed() -> void:
	$"../CameraManager".goto_player()
	$"../AudioManager".play_click()
	$"../UI/Wardrobe".reset_previews_to_equipped()
	change_menu(Menu.WARDROBE)
func _on_shop_button_pressed() -> void:
	change_menu(Menu.SHOP)
	$"../AudioManager".play_click()
func _on_back_btn_pressed() -> void:
	change_menu(Menu.START)
	$"../AudioManager".play_click()
	$"../AudioManager".play_music()


func changeScore(new_score:int):
	$"../UI/Level".increase_score(new_score)
func updateGameOver(final_score : int):
	$"../UI/GameOver/ManuBack/FinalScoreLabel".text = str(final_score)

func changecoin(new_coin:int):
	$"../UI/Wardrobe/CoinBackground/CoinLabel".text = str(new_coin)
	$"../UI/Shop/Fade/CoinBackground/CoinLabel".text = str(new_coin)
	$"../UI/Level/CoinBackground/CoinLabel".text = str(new_coin)
	


func _on_retry_button_clicked():
	$"../AudioManager".play_click()
	retry_pressed.emit()

func _on_menu_button_clicked():
	$"../AudioManager".play_click()
	menu_pressed.emit()
	
func _on_contine_button_clicked():
	$"../AudioManager".play_click()
	continue_pressed.emit()

func _ad_failed():
	$"../UI/Ad_failed_label".visible = true;
	await get_tree().create_timer(2.0).timeout
	$"../UI/Ad_failed_label".visible = false;
	
func reward_msg():
	$"../UI/reward_msg".visible = true;
	await get_tree().create_timer(2.0).timeout
	$"../UI/reward_msg".visible = false;
	
