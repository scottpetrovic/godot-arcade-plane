extends Node3D

func is_player_on_landing_pad():
	return $AircraftCarrier/Runway.is_player_on_landing_strip
