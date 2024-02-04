//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 04/02/2024 16:25
//=============================================================================//

package audio

import "core:log"
import "core:math/linalg"
import "core:strings"

import "vendor:miniaudio"

Music_File :: struct {
    path: string,
    handle: miniaudio.sound,
    pause_cursor: u64,
    paused: b32
}

music_file_load :: proc(file: ^Music_File, path: string) {
    file.path = path
    new_string := strings.clone_to_cstring(path)

    err := miniaudio.sound_init_from_file(&audio_system.engine, new_string, u32(miniaudio.sound_flags.STREAM | miniaudio.sound_flags.NO_SPATIALIZATION), nil, nil, &file.handle)
    if err != miniaudio.result.SUCCESS {
        log.errorf("Failed to load music file: %s", path)
        log.error(err)
    }
    file.paused = false
    delete(new_string)
}

music_file_play :: proc(file: ^Music_File) {
    miniaudio.sound_start(&file.handle)
}

music_file_stop :: proc(file: ^Music_File) {
    miniaudio.sound_stop(&file.handle)
    miniaudio.sound_seek_to_pcm_frame(&file.handle, 0)
}

music_file_pause :: proc(file: ^Music_File) {
    if !file.paused {
        miniaudio.sound_stop(&file.handle)
        file.paused = true
    } else {
        music_file_play(file)
        file.paused = false
    }
}

music_file_free :: proc(file: ^Music_File) {
    miniaudio.sound_uninit(&file.handle)
}
