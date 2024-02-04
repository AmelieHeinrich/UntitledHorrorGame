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

music_file_load :: proc(path: string) -> Music_File {
    file: Music_File

    file.path = path
    new_string := strings.clone_to_cstring(path)
    err := miniaudio.sound_init_from_file(&audio_system.engine, new_string, u32(miniaudio.sound_flags.ASYNC | miniaudio.sound_flags.STREAM | miniaudio.sound_flags.DECODE), nil, nil, &file.handle)
    if err != miniaudio.result.SUCCESS {
        log.errorf("Failed to load music file: %s", path)
        log.error(err)
    }
    file.paused = false
    delete(new_string)

    return file
}

music_file_play :: proc(file: ^Music_File) {
    miniaudio.sound_start(&file.handle)
}

music_file_stop :: proc(file: ^Music_File) {
    miniaudio.sound_stop(&file.handle)
}

music_file_pause :: proc(file: ^Music_File) {
    if !file.paused {
        miniaudio.sound_get_cursor_in_pcm_frames(&file.handle, &file.pause_cursor)
        music_file_stop(file)
        file.paused = true
    } else {
        miniaudio.sound_set_start_time_in_pcm_frames(&file.handle, file.pause_cursor)
        music_file_play(file)
        file.paused = false
    }
}

music_file_free :: proc(file: ^Music_File) {
    miniaudio.sound_uninit(&file.handle)
}
