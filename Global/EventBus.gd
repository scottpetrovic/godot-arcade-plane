extends Node

# Global events. If you find yourself starting to pass around
# signals between components too much with hierarchies, 
# put it globally to decouple yourself
signal player_crashed(location: String)

signal skydiver_landed_on_target(points: float)
signal skydiver_landed_off_target()
