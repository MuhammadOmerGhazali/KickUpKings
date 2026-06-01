extends Node
class_name Ad_manager

var _ad_view: AdView
var _interstitial_ad : InterstitialAd
var _rewarded_ad : RewardedAd
var rewarded_ready := false

var _full_screen_content_callback := FullScreenContentCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()

func _ready():
	_full_screen_content_callback.on_ad_clicked = func() -> void:
		print("on_ad_clicked")
	_full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("on_ad_dismissed_full_screen_content")
	_full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error : AdError) -> void:
		print("on_ad_failed_to_show_full_screen_content")
	_full_screen_content_callback.on_ad_impression = func() -> void:
		print("on_ad_impression")
	_full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("on_ad_showed_full_screen_content")
	# Initialize only once at app start
	MobileAds.initialize()
	await get_tree().create_timer(1.0).timeout
	_create_ad_view()
	_on_load_banner_pressed() #load and display banner ad
	_on_load_intersetial_pressed() #load intersetial ad in advance 
	_on_load_rewarded_pressed() #load rewarded ad in advance and then just show it on need
	
	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item : RewardedItem):
		print("on_user_earned_reward, rewarded_item: rewarded", rewarded_item.amount, rewarded_item.type)
		
	#if reward_callback.is_valid():
		#reward_callback.call()
		#reward_callback = Callable()

func _create_ad_view() -> void:
	# free memory if already exists
	if _ad_view:
		destroy_ad_view()

	var unit_id: String

	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/6300978111"
	elif OS.get_name() == "iOS":
		#unit_id = "ca-app-pub-3940256099942544/2934735716"
		unit_id = "ca-app-pub-7103096018535648/7610735585"

	_ad_view = AdView.new(
		unit_id,
		AdSize.BANNER,
		AdPosition.Values.TOP
	)
	#it is my line 
	register_ad_listener()
func _on_load_banner_pressed():
	if _ad_view == null:
		_create_ad_view()
	var ad_request := AdRequest.new()
	_ad_view.load_ad(ad_request)
	#my line to sure showing banner ad 
	_ad_view.show()
func register_ad_listener() -> void:
	if _ad_view != null:
		var ad_listener := AdListener.new()

		ad_listener.on_ad_failed_to_load = func(load_ad_error : LoadAdError) -> void:
			print("_on_ad_failed_to_load: " + load_ad_error.message)
		ad_listener.on_ad_clicked = func() -> void:
			print("_on_ad_clicked")
		ad_listener.on_ad_closed = func() -> void:
			print("_on_ad_closed")
		ad_listener.on_ad_impression = func() -> void:
			print("_on_ad_impression")
		ad_listener.on_ad_loaded = func() -> void:
			print("_on_ad_loaded")
		ad_listener.on_ad_opened = func() -> void:
			print("_on_ad_opened")

		_ad_view.ad_listener = ad_listener
		

func destroy_ad_view() -> void:
	if _ad_view:
		_ad_view.destroy()
		_ad_view = null
		
func _on_load_intersetial_pressed():
	#free memory
	if _interstitial_ad:
		#always call this method on all AdFormats to free memory on Android/iOS
		_interstitial_ad.destroy()
		_interstitial_ad = null

	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/1033173712"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3940256099942544/4411468910"

	var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()
	interstitial_ad_load_callback.on_ad_failed_to_load = func(adError : LoadAdError) -> void:
		print(adError.message)

	interstitial_ad_load_callback.on_ad_loaded = func(interstitial_ad : InterstitialAd) -> void:
		print("interstitial ad loaded" + str(interstitial_ad._uid))
		_interstitial_ad = interstitial_ad

	InterstitialAdLoader.new().load(unit_id, AdRequest.new(), interstitial_ad_load_callback)
	
	#my function for handling callback
func show_intersetial_ad(callback: Callable = Callable()) -> bool:

	if _interstitial_ad:

		#after_ad_callback = callback

		_interstitial_ad.show()

		_on_load_intersetial_pressed()

		return true

	return false
	
	#plugin function
#func show_intersetial_ad():
	#if _interstitial_ad:
		#_interstitial_ad.show()
		##my line to load next ad in advance
		#_on_load_intersetial_pressed()
		
func _on_load_rewarded_pressed():
	#free memory
	if _rewarded_ad:
		#always call this method on all AdFormats to free memory on Android/iOS
		_rewarded_ad.destroy()
		_rewarded_ad = null

	var unit_id : String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3940256099942544/5224354917"
	elif OS.get_name() == "iOS":
		#unit_id = "ca-app-pub-3940256099942544/1712485313"
		unit_id = "ca-app-pub-7103096018535648/4984572245"

	var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
	rewarded_ad_load_callback.on_ad_failed_to_load = func(adError : LoadAdError) -> void:
		print(adError.message)
		rewarded_ready = false
	rewarded_ad_load_callback.on_ad_loaded = func(rewarded_ad : RewardedAd) -> void:
		print("rewarded ad loaded" + str(rewarded_ad._uid))
		_rewarded_ad = rewarded_ad
		rewarded_ready = true
		_rewarded_ad.full_screen_content_callback = _full_screen_content_callback

	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)

#func show_rewarded_ad():
	#if _rewarded_ad:
		#_rewarded_ad.show(on_user_earned_reward_listener)
		
func show_rewarded_ad() -> bool:

	if rewarded_ready and _rewarded_ad:

		rewarded_ready = false

		_rewarded_ad.show(on_user_earned_reward_listener)

		# preload next ad
		_on_load_rewarded_pressed()

		return true

	return false
	
	
#func show_rewarded_ad(callback: Callable) -> bool:
#
	#if _rewarded_ad:
#
		#reward_callback = callback
#
		#_rewarded_ad.show(on_user_earned_reward_listener)
#
		#_on_load_rewarded_pressed()
#
		#return true
#
	#return false
