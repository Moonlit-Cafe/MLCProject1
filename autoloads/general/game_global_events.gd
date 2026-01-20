## This is where all the main and common signals are located, otherwise referred to as a SignalBus
extends Node

@warning_ignore_start("unused_signal")
signal action_selected(ac: Action)
signal attack_tile(tile:BattleTile)
signal battle_removed(node: Variant)
signal battle_tile_selected
signal battle_end
signal game_end
signal hp_changed
signal player_turn
signal stop_dragging
signal weapon_open

signal thinking
signal act(a: Ability, b: String)
