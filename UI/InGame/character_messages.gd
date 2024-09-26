extends HBoxContainer

@onready var character_portrait: Sprite2D = $CharacterPortrait
@onready var rich_text_label: RichTextLabel = $ColorRect/RichTextLabel

func _ready() -> void:
	self.visible = false
	await get_tree().create_timer(2.0).timeout
	await start_messages_async([
		"It's finally the big day. Enough of the simulator. It is time to fly!",
		"Remember your training and stay focused.",
		"Good luck on your mission!"
	])

func start_messages_async(messages: Array) -> void:
	self.visible = true  # Show the GUI element once at the beginning
	for message in messages:
		await show_message(message)
		
	# Hide the GUI element after all messages are done
	self.visible = false


func show_message(message_text: String) -> void:
	rich_text_label.visible_ratio = 0.0
	rich_text_label.text = message_text
	
	# Wait for the message to finish displaying
	while rich_text_label.visible_ratio < 1.0:
		await get_tree().process_frame
	
	# Wait for the message to be read
	await get_tree().create_timer(5.0).timeout

func _process(delta: float) -> void:
	if rich_text_label.visible_ratio < 1.0:
		rich_text_label.visible_ratio += delta * 0.3
