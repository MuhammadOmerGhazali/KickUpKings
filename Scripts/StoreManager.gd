extends Node

const Types = preload("res://addons/godot-iap/types.gd")

signal coins_awarded(amount: int)
signal ads_removed()
signal prices_loaded(prices_dict: Dictionary)

var consumable_ids = [
	"com.kickupkings.kickupkings.verytinycoinpack",
	"com.kickupkings.kickupkings.tinycoinpack",
	"com.kickupkings.kickupkings.smallcoinpack",
	"com.kickupkings.kickupkings.mediumcoinpack",
	"com.kickupkings.kickupkings.largecoinpack",
	"com.kickupkings.kickupkings.verylargecoinpack",
    "android.test.purchased"
]

var non_consumable_ids = ["com.kickupkings.removeads"]

func _ready():
	# If we are on PC/Editor, don't try to connect to Google/Apple servers
	if OS.has_feature("editor") or (OS.get_name() != "Android" and OS.get_name() != "iOS"):
		print("IAP: Running on Desktop/Editor. Mock system initialized.")
		return

	print("Available Query Types: ", Types.ProductQueryType)
	
	# --- THE FIX ---
	# We deleted wrapper_script.new(). Instead, we directly use the 
	# 'GodotIap' autoload that Godot created for us automatically.
	
	# 1. Connect the official signals
	GodotIapPlugin.connected.connect(_on_connected)
	GodotIapPlugin.purchase_updated.connect(_on_purchase_updated)
	GodotIapPlugin.purchase_error.connect(_on_purchase_error)
	
	# 2. Initialize connection
	var success = GodotIapPlugin.init_connection()
	print("IAP Init result: ", success)


func _on_connected():
	print("Store connected successfully!")
	fetch_products()


func fetch_products():
	var request = Types.ProductRequest.new()
	request.skus = consumable_ids + non_consumable_ids
	request.type = Types.ProductQueryType.IN_APP
	
	var products: Array = await GodotIapPlugin.fetch_products(request)
	
	# Create a dictionary to hold [sku: string_price] pairs
	var localized_prices = {}
	
	print("--- Available Products ---")
	for product in products:
		print(product.id, " - ", product.display_price)
		# Store the formatted string (e.g., "$0.99", "0,99 €", "Rs 280")
		localized_prices[product.id] = product.display_price
	print("--------------------------")
	
	# Send the dictionary over to the Shop UI script
	emit_signal("prices_loaded", localized_prices)


func buy_item(sku: String):
	print("Initiating purchase for: ", sku)

	# --- MOCK SYSTEM FOR PC TESTING ---
	if OS.has_feature("editor") or (OS.get_name() != "Android" and OS.get_name() != "iOS"):
		print("IAP [MOCK]: Simulating successful purchase on PC for: ", sku)
		
		var mock_purchase = {
			"product_id": sku,
			"order_id": "mock-pc-order-12345",
			"purchase_token": "mock-token-abcde"
		}
		_on_purchase_updated(mock_purchase)
		return
	# ---------------------------------
	
	# 1. Create the root properties object
	var props = Types.RequestPurchaseProps.new()
	props.type = Types.ProductQueryType.IN_APP
	
	# 2. Create the platform-specific wrapper
	var platforms = Types.RequestPurchasePropsByPlatforms.new()
	
	# 3. Setup Apple
	var apple_props = Types.RequestPurchaseIosProps.new()
	apple_props.sku = sku
	platforms.apple = apple_props
	
	# 4. Setup Google
	var google_props = Types.RequestPurchaseAndroidProps.new()
	var android_skus: Array[String] = [sku]
	google_props.skus = android_skus
	platforms.google = google_props
	
	# 5. Attach the platforms to the main request
	props.request = platforms
	
	# Trigger the actual native purchase on mobile devices via the Autoload
	await GodotIapPlugin.request_purchase(props)


# --- Callbacks ---

func _on_purchase_updated(purchase: Dictionary):
	var product_id = purchase.get("product_id", "")
	print("Purchase successful for: ", product_id)
	
	# Give the player their item
	unlock_content(product_id)
	
	# Finish the transaction
	if GodotIapPlugin.has_method("finish_transaction"):
		await GodotIapPlugin.finish_transaction(purchase, true)
		print("Transaction finished and acknowledged.")
	else:
		print("IAP [MOCK]: Skipped native transaction finish.")


func _on_purchase_error(error: Dictionary):
	var code = error.get("code", "UNKNOWN")
	var msg = error.get("message", "No message provided")
	print("Purchase failed! Error [", code, "]: ", msg)


func unlock_content(product_id: String):
	match product_id:
		"com.kickupkings.removeads":
			print("Ads removed forever!")
			emit_signal("ads_removed")
			
		"com.kickupkings.kickupkings.verytinycoinpack":
			print("Added Very Tiny Coin Pack!")
			emit_signal("coins_awarded", 1000)
			
		"com.kickupkings.kickupkings.tinycoinpack":
			print("Added Tiny Coin Pack!")
			emit_signal("coins_awarded", 3500)
			
		"com.kickupkings.kickupkings.smallcoinpack":
			print("Added Small Coin Pack!")
			emit_signal("coins_awarded", 6500)
			
		"com.kickupkings.kickupkings.mediumcoinpack":
			print("Added Medium Coin Pack!")
			emit_signal("coins_awarded", 15000)
			
		"com.kickupkings.kickupkings.largecoinpack":
			print("Added Large Coin Pack!")
			emit_signal("coins_awarded", 35000)
			
		"com.kickupkings.kickupkings.verylargecoinpack":
			print("Added Very Large Coin Pack!")
			emit_signal("coins_awarded", 100000)
			
		"android.test.purchased":
			print("Added Test Pack Coins!")
			emit_signal("coins_awarded", 999)
			
		_:
			print("Unknown product ID purchased: ", product_id)
