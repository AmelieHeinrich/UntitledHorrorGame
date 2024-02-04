//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 04/02/2024 16:01
//=============================================================================//

package audio

import "core:log"
import "core:math/linalg"
import "core:strings"

import "vendor:miniaudio"

Sound_Effect :: struct {
    path: string,
    handle: miniaudio.sound,
    spatialized: b32,
    position: linalg.Vector3f32
}

sound_effect_load :: proc(path: string, spatialized: b32) -> Sound_Effect {
    effect: Sound_Effect

    effect.path = path
    effect.spatialized = spatialized
    err := miniaudio.sound_init_from_file(&audio_system.engine, strings.clone_to_cstring(path), u32(miniaudio.sound_flags.DECODE), nil, nil, &effect.handle)
    if err != miniaudio.result.SUCCESS {
        log.errorf("Failed to load sound effect: %s", path)
        log.error(err)
    }
    
    if effect.spatialized {
        miniaudio.sound_set_spatialization_enabled(&effect.handle, true)
    }

    return effect
}

sound_effect_set_position :: proc(effect: ^Sound_Effect, pos: linalg.Vector3f32) {
    miniaudio.sound_set_position(&effect.handle, pos.x, pos.y, pos.z)
}

sound_effect_copy :: proc(effect: ^Sound_Effect) -> Sound_Effect {
    copied_effect: Sound_Effect
    
    err := miniaudio.sound_init_copy(&audio_system.engine, &effect.handle, u32(miniaudio.sound_flags.DECODE),  nil, &copied_effect.handle)
    if err != miniaudio.result.SUCCESS {
        log.errorf("Failed to copy sound effect: %s")
        log.error(err)
    }

    return copied_effect
}

sound_effect_play :: proc(effect: ^Sound_Effect) {
    miniaudio.sound_start(&effect.handle)
}

sound_effect_stop :: proc(effect: ^Sound_Effect) {
    miniaudio.sound_stop(&effect.handle)
}

sound_effect_free :: proc(effect: ^Sound_Effect) {
    miniaudio.sound_uninit(&effect.handle)
}
