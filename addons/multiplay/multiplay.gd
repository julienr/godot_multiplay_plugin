# References:
# Original github issue:
# https://github.com/godotengine/godot/issues/7008
# Godot editor play buttons setup:
# https://github.com/godotengine/godot/blob/a7f49ac9a107820a62677ee3fb49d38982a25165/editor/editor_node.cpp#L6265
# Custom play button plugin:
# https://github.com/MightyPrinny/godot-custom-play-scene-button/blob/master/addons/fabianlc_custom_play_scene_button/plugin.gd

tool
extends EditorPlugin

var main_scene_filename
var button
var pids = []

var editor_node

func _enter_tree():
	main_scene_filename = ProjectSettings.globalize_path(ProjectSettings.get_setting("application/run/main_scene"))
	button = preload("res://addons/multiplay/button.tscn").instance()
	button.connect("pressed", self, "on_click")
	add_control_to_container(CONTAINER_TOOLBAR, button)
	# See how the hierarchy is built in https://github.com/godotengine/godot/blob/a7f49ac9a107820a62677ee3fb49d38982a25165/editor/editor_node.cpp#L5767
	var gui_base = get_editor_interface().get_base_control()
	var theme_base = gui_base.get_parent()
	editor_node = theme_base.get_parent()
	editor_node.connect("stop_pressed", self, "on_editor_stop_pressed")
	

func _exit_tree():
	_killall()
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.free()

func on_click():
	editor_node._quick_run()
	var pid = OS.execute(OS.get_executable_path(), [main_scene_filename], false)
	pids.append(pid)
	
func _killall():
	for pid in pids:
		OS.kill(pid)

func on_editor_stop_pressed():
	_killall()
