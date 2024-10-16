extends Node

# Global events. If you find yourself starting to pass around
# signals between components too much with hierarchies, 
# put it globally to decouple yourself
signal player_crashed(location: String)

# Inside the player we have an area that looks for bullet
# if we are being attacked, send a signal
# this is only used by the rearview mirror to turn on/off
signal player_attacked_from_behind()

signal all_objectives_complete()
