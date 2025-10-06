## This is where all the main and common signals are located, otherwise referred to as a SignalBus
extends Node

signal action_selected(ac: Action)
signal battle_removed(node: Variant)
signal battle_end
signal game_end
signal hp_changed
signal player_turn
signal stop_dragging
