//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 16/01/2024 15:07
//=============================================================================//

package game

Event_Type :: enum {
    RESIZE,
    GAMEPAD_CONNECT,
    GAMEPAD_DISCONNECT,
    KEY_PRESSED,
    KEY_RELEASED,
    MOUSE_BUTTON_PRESSED,
    MOUSE_BUTTON_RELEASED,
    MOUSE_SCROLL,
}

Event_Data :: struct #raw_union {
    int64: [2]i64,
    uint64: [2]u64,
    float64: [2]f64,
    int32: [4]i32,
    uint32: [4]u32,
    float32: [4]f32,
    int16: [8]i16,
    uint16: [8]u16,
    int8: [16]i8,
    uint8: [16]u8,
}

Registered_Events :: struct {
    callbacks: [dynamic]proc(type: Event_Type, data: Event_Data),
}

Event_System :: struct {
    events: map[Event_Type]Registered_Events,
}

event_system_init :: proc(system: ^Event_System) {
    system.events = make(map[Event_Type]Registered_Events)
}

event_system_free :: proc(system: ^Event_System) {
    delete(system.events)
}

event_system_register :: proc(system: ^Event_System, type: Event_Type, callback: proc(type: Event_Type, data: Event_Data)) {
    events := system.events[type]
    append(&events.callbacks, callback)
    system.events[type] = events
}

event_system_fire :: proc(system: ^Event_System, type: Event_Type, data: Event_Data) {
    for callback in system.events[type].callbacks {
        callback(type, data)
    }
}
