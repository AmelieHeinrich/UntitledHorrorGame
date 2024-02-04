//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 04/02/2024 12:12
//=============================================================================//

package audio

import "core:log"
import "core:math/linalg"

import "vendor:miniaudio"

Audio_System :: struct {
    device: miniaudio.device,
    engine: miniaudio.engine
}

audio_system: Audio_System

audio_system_init :: proc() {
    config := miniaudio.device_config_init(miniaudio.device_type.playback)
    config.playback.format = miniaudio.format.s16
    config.playback.channels = 2 // TODO: Surround sound with 8 channels?
    config.sampleRate = 48000

    err := miniaudio.device_init(nil, &config, &audio_system.device)
    if err != miniaudio.result.SUCCESS {
        log.error("Failed to create miniaudio device!")
        log.error(err)
    }

    engine_config := miniaudio.engine_config_init()
    engine_config.pDevice = &audio_system.device
    engine_config.listenerCount = 1;

    err = miniaudio.engine_init(&engine_config, &audio_system.engine)
    if err != miniaudio.result.SUCCESS {
        log.error("Failed to create miniaudio device!")
        log.error(err)
    }

    log.info("Initialised audio engine!")
}

audio_system_destroy :: proc() {
    miniaudio.engine_uninit(&audio_system.engine)
    miniaudio.device_uninit(&audio_system.device)
}

audio_system_set_listener_info :: proc(position: linalg.Vector3f32, front: linalg.Vector3f32) {
    miniaudio.engine_listener_set_position(&audio_system.engine, 0, position.x, position.y, position.z)
    miniaudio.engine_listener_set_direction(&audio_system.engine, 0, front.x, front.y, front.z)
}