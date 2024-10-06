extends Label

var current_score: int = 0
var original_scale: Vector2
var displayed_score: int = 0

@export var scale_duration: float = 0.5
@export var score_transition_duration: float = 1.0

func _ready():
	original_scale = scale  # Store the original scale

func _process(delta: float) -> void:
	var actual_score = GameManager.get_destruction_points()
	text = str(displayed_score).pad_zeros(11)
	
	if actual_score != current_score:
		score_updated_animation()
		smooth_score_transition(actual_score)
		current_score = actual_score

func score_updated_animation():
	# Create a tween for smooth scaling
	var scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.set_ease(Tween.EASE_IN_OUT)
	scale_tween.tween_property(self, "scale", original_scale * 1.2, scale_duration / 2)
	scale_tween.tween_property(self, "scale", original_scale, scale_duration / 2)

func smooth_score_transition(new_score: int):
	# Create a tween for smooth score transition
	var score_tween = create_tween()
	score_tween.set_trans(Tween.TRANS_LINEAR)  # Linear transition for score
	score_tween.tween_property(self, "displayed_score", new_score, score_transition_duration)

# This function is used by the tween to update the displayed score
func set_displayed_score(value: int):
	displayed_score = value
	# Update the text immediately when the displayed_score changes
	text = str(displayed_score).pad_zeros(11)
