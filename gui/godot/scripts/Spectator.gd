# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2018 Sacha Delanoue

extends Node

const DumpReader = preload("res://scripts/DumpReader.gd")

var socket = null
var waiting = false
var playing = false
var animating = false

func _init_socket():
	var port = 0
	for arg in OS.get_cmdline_args():
		if arg.begins_with("-socket="):
			port = int(arg.right(8))
	socket = StreamPeerTCP.new()
	var connected = socket.connect_to_host("127.0.0.1", port)
	if connected != OK:
		print("Could not connect")

func _ready():
	_init_socket()
	var available = 0
	while available == 0:
		available = socket.get_available_bytes()
	var dump = socket.get_string(available)
	var json = JSON.parse(dump).result
	var init = DumpReader.parse_turn(json)
	$GameState.init(init.walls, init.players[0].agents + init.players[1].agents)
	for agent in $GameState/TileMap.agents:
		 agent.connect("finished_moving", self, "_finish_animating")
	$GameState/Info.players[0].name = init.players[0].name
	$GameState/Info.players[1].name = init.players[1].name
	for alien_input in init.aliens:
		var alien = $GameState/TileMap.Alien.new()
		alien.pos = alien_input.pos
		alien.points = alien_input.points
		alien.first_turn = alien_input.first_turn
		alien.duration = alien_input.duration
		alien.capture = alien_input.capture
		$GameState/TileMap.aliens.append(alien)
	$GameState.set_turn(0)

func _finish_animating():
	animating = false

func _process(delta):
	if waiting:
		var available = socket.get_available_bytes()
		if available:
			var dump = socket.get_string(available)
			var json = JSON.parse(dump).result
			var state = DumpReader.parse_turn(json)
			for i in range(state.aliens.size()):
				$GameState/TileMap.aliens[i].capture = state.aliens[i].capture
			$GameState.set_turn(state.roundNumber * 3)
			waiting = false
	if playing and not animating:
		socket.put_utf8_string("NEXT")
		waiting = true
	if Input.is_action_just_pressed("ui_select"):
		playing = !playing
