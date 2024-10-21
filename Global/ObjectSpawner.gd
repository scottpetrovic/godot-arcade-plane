extends Node

var BulletObjectHitParticle = preload("res://Effects/Particles/BulletObjectHitParticle/BulletObjectHitParticle.tscn")
var BulletObjectDebrisParticles = preload("res://Effects/Particles/ExplosionDebrisParticles/ExplosionDebrisParticles.tscn")
var NicerExplosionParticles = preload("res://Effects/Particles/BetterExplosion/BetterExplosionParticle.tscn")
var FuelCanScene = preload("res://Props/FuelCan/FuelCan.tscn")
var ObjectOnFireParticles = preload("res://Effects/Particles/ObjectOnFireParticles/object_on_fire_particles.tscn")
var CraterScene = preload("res://Props/Crater/Crater.tscn")
var KaijuEntranceParticles = preload("res://Effects/KaijuGroundBreakParticles/KaijuEmergeParticles.tscn")

var GateCheckpoint = preload("res://Props/GateCheckpoint/GateCheckpoint.tscn")

func create_fuel_can(starting_position: Vector3) -> void:
	var instance_fuelcan = FuelCanScene.instantiate()
	get_tree().root.add_child(instance_fuelcan)
	instance_fuelcan.global_position = starting_position

func create_gate_checkpoint(starting_position: Vector3) -> void:
	var instance = GateCheckpoint.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = starting_position

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
	
