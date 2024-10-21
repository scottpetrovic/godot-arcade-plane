extends Node

var BulletObjectHitParticle = preload("res://Effects/Particles/BulletObjectHitParticle/BulletObjectHitParticle.tscn")
var BulletObjectDebrisParticles = preload("res://Effects/Particles/ExplosionDebrisParticles/ExplosionDebrisParticles.tscn")
var NicerExplosionParticles = preload("res://Effects/Particles/BetterExplosion/BetterExplosionParticle.tscn")
var FuelCanScene = preload("res://Props/FuelCan/FuelCan.tscn")
var ObjectOnFireParticles = preload("res://Effects/Particles/ObjectOnFireParticles/object_on_fire_particles.tscn")
var CraterScene = preload("res://Props/Crater/Crater.tscn")
var KaijuEntranceParticles = preload("res://Effects/KaijuGroundBreakParticles/KaijuEmergeParticles.tscn")


# keep track of global things that need to persist between scenes
var current_level_time: float = 0.0 # store in seconds
var current_level_success_status: bool = false
var current_level_landing_score: float = 0
var current_level_objectives_score: int = 0

var _current_level_destruction_points: int = 0 # for blowing up stuff
var current_level_remaining_enemies: int = 0 # how many levels for round

var current_level_number: int = 1
var current_vehicle: String = "" # Plane or Skydiving
var current_map: String = "" # AircraftCarrier or Airport

var is_level_1_finished: bool = false
var level_1_best_time: float = 0.0 #  0 == not beat

var is_level_2_finished: bool = false
var level_2_best_time: float = 0.0 #  0 == not beat

# different objects at different levels need to reference this
var _player_reference: Player

# keep track of what upgrades we have achieved
enum ShootType { SINGLE, DOUBLE}
var current_player_shoot_mode = ShootType.SINGLE
var curent_player_shoot_delay_time = 0.2

func get_destruction_points() -> int:
	return _current_level_destruction_points

func add_destruction_points(points: int)-> void:
	_current_level_destruction_points += points

func get_player() -> Player:
	return _player_reference
	
func set_player(player_object: Player) -> void:
	_player_reference = player_object

func set_current_map(cur_map: String):
	current_map = cur_map

func set_current_vehicle(cur_vehicle: String):
	current_vehicle = cur_vehicle

func go_to_map_selection():
	SceneTransition.change_scene("res://UI/MapSelect/MapSelect.tscn")

func go_to_vehicle_selection_screen():
	SceneTransition.change_scene("res://UI/VehicleSelect/VehicleSelect.tscn")

func go_to_mission_overview(fade_music: bool = false):
	SceneTransition.change_scene("res://UI/MissionEndOverview/MissionEndOverview.tscn", fade_music)

func go_to_main_menu():
	SceneTransition.change_scene("res://UI/MainMenu/MainMenu.tscn")

func set_level_complete(level_number: int, level_time: float):

	current_level_time = level_time

	if level_number == 1:
		is_level_1_finished = true
		
		if current_level_time > level_1_best_time:
			level_1_best_time = current_level_time 

	if level_number == 2:
		is_level_2_finished = true
		
		if current_level_time > level_2_best_time:
			level_2_best_time = current_level_time

func go_to_next_level():
	
	# reset current level related scores since we are starting over
	current_level_success_status = false # reset current level success
	current_level_landing_score = 0
	current_level_time = 0
	current_level_objectives_score = 0

	SceneTransition.change_scene("res://Levels/DemoLevel.tscn", true)

	GlobalAudio.start_music_theme()


func format_elapsed_time(elapsed: float) -> String:
	var minutes = int(elapsed/ 60.0)
	var seconds = int(elapsed) % 60
	var milliseconds = int((elapsed - int(elapsed)) * 1000)
	return str(minutes) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(3)


func create_fuel_can(starting_position: Vector3) -> void:
	var instance_fuelcan = FuelCanScene.instantiate()
	get_tree().root.add_child(instance_fuelcan)
	instance_fuelcan.global_position = starting_position

func create_enemy(enemy_object: Node3D, pos: Vector3) -> void:
	GameManager.current_level_remaining_enemies += 1 # keep track of enemies
	get_tree().current_scene.add_child(enemy_object)
	enemy_object.global_position = pos

func create_explosion(starting_position: Vector3) -> void:
	# create particle effects since we blew up
	# instanatiate the effects at the root level since we 
	# are about to delete this object
	var instance_explosion = NicerExplosionParticles.instantiate()
	get_tree().root.add_child(instance_explosion)
	instance_explosion.global_position = starting_position

	# attach sound effect node to explosion instance
	var audio_player: AudioStreamPlayer3D = instance_explosion.get_node("SFX")
	audio_player.play()

func create_kaiju_entrance_particles(starting_position: Vector3) -> void:
	var instance_expl: GPUParticles3D = KaijuEntranceParticles.instantiate()
	get_tree().root.add_child(instance_expl)
	instance_expl.global_position = starting_position
	instance_expl.emitting = true

func create_crater(starting_position, scale_fac: float = 1.0) -> void:
	var crator_instance: StaticBody3D = CraterScene.instantiate()
	crator_instance.scale = Vector3(scale_fac,scale_fac,scale_fac)
	
	get_tree().root.add_child(crator_instance)
	crator_instance.global_position = starting_position
	crator_instance.global_position.y = 0 # make sure it is on ground

func create_stall_smoke_effects(object_ref: Node3D) -> void:
	var instance_smoke: ObjectOnFireParticles = ObjectOnFireParticles.instantiate()
	get_tree().root.add_child(instance_smoke)
	instance_smoke.set_object_to_follow(object_ref)
	
