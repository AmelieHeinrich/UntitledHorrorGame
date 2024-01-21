//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 20/01/2024 13:43
//=============================================================================//

package base

import "vendor:sdl2"

Input_Event :: enum {
    PRESSED,
    RELEASED,
    REPEAT
}

Input_System :: struct {
    keys: map[sdl2.Keycode]u8,
    buttons: map[u8]u8,
    mod_state: sdl2.Keymod,
    mouse_delta: [2]i32,
    mouse_position: [2]i32,
    mouse_wheel: [2]i32
    // TODO: Assign callbacks/actions to keys/buttons
}

input_system: Input_System

input_system_init :: proc() {
    input_system.keys = make(map[sdl2.Keycode]u8)
    input_system.buttons = make(map[u8]u8)
}

input_system_free :: proc() {
    delete(input_system.keys)
    delete(input_system.buttons)
}

input_system_handle_key :: proc(event: ^sdl2.KeyboardEvent) {
    input_system.keys[event.keysym.sym] = event.state
    input_system.mod_state = sdl2.GetModState()
}

input_system_handle_button :: proc(event: ^sdl2.MouseButtonEvent) {
    input_system.buttons[event.button] = event.state
}

input_system_handle_wheel :: proc(x: i32, y: i32) {
    input_system.mouse_wheel[0] = x
    input_system.mouse_wheel[1] = y
}

input_system_handle_mouse_delta :: proc(x: i32, y: i32) {
    input_system.mouse_delta[0] = x
    input_system.mouse_delta[1] = y
}

input_system_handle_mouse_position :: proc(x: i32, y: i32) {
    input_system.mouse_position[0] = x
    input_system.mouse_position[1] = y
}

input_system_grab_mouse :: proc() {
    sdl2.SetRelativeMouseMode(true)
}

input_system_release_mouse :: proc() {
    sdl2.SetRelativeMouseMode(false)
}

// ACCESSORS

input_system_is_key_pressed :: proc(key: sdl2.Keycode) -> bool {
    return (input_system.keys[key] == sdl2.PRESSED)
}

input_system_is_key_released :: proc(key: sdl2.Keycode) -> bool {
    return (input_system.keys[key] == sdl2.RELEASED)
}

input_system_is_button_pressed :: proc(button: u8) -> bool {
    return (input_system.buttons[button] == sdl2.PRESSED)
}

input_system_is_button_released :: proc(button: u8) -> bool {
    return (input_system.buttons[button] == sdl2.RELEASED)
}

input_system_get_mouse_delta :: proc() -> [2]i32 {
    return input_system.mouse_delta
}

input_system_get_mouse_wheel :: proc() -> [2]i32 {
    return input_system.mouse_wheel
}

input_system_get_mouse_position :: proc() -> [2]i32 {
    return input_system.mouse_position
}
