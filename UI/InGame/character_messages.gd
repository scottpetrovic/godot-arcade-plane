extends HBoxContainer

@onready var rich_text_label: RichTextLabel = $ColorRect/VBoxContainer/RichTextLabel
var animation_duration: float = 1.0

func _ready() -> void:
	self.visible = false
	start_mission_message()
	EventBus.all_objectives_complete.connect(_on_mission_complete)


func start_mission_message() -> void:
	await get_tree().create_timer(2.0).timeout
	await start_messages_async([
		"It's finally the big day. Enough of the simulator. It is time to fly!",
		"Good luck on your mission!"
	])

func _on_mission_complete() -> void:
	await get_tree().create_timer(4.0).timeout
	await start_messages_async([
		"That takes care of the last one. Come on back home"
	])

func start_messages_async(messages: Array) -> void:
	rich_text_label.text = '' # clear pre-existing text
	await show_gui_element()
	
	for message in messages:
		rich_text_label.text = '' # clear text from previous message
		await show_message(message)

	await hide_gui_element()

func show_gui_element() -> void:
	scale.y = 0.1
	visible = true
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale:y", 1.0, animation_duration)
	await tween.finished

func hide_gui_element() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale:y", 0.1, animation_duration)
	await tween.finished
	visible = false

func show_message(message_text: String) -> void:
	rich_text_label.visible_ratio = 0.0
	rich_text_label.text = message_text
	
	# Wait for the message to finish displaying
	while rich_text_label.visible_ratio < 1.0:
		await get_tree().process_frame
	
	# Wait for the message to be read
	await get_tree().create_timer(4.0).timeout

func _process(delta: float) -> void:
	if rich_text_label.visible_ratio < 1.0:
		rich_text_label.visible_ratio += delta * 0.6
