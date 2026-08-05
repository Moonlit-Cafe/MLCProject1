## This is where all the main and common signals are located, otherwise referred to as a SignalBus
extends Node

@warning_ignore_start("unused_signal")
signal battle_removed(node: Variant) ## Emitted to have a specific node removed from trackers
signal game_end ## Emitted upon the game ending
signal player_turn ## Emitted when the player has completed their turn
signal weapon_open ## Emitted when a weapon item is clicked to open weapon info

signal thinking
