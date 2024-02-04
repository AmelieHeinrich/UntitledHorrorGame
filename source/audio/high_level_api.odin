//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 04/02/2024 16:26
//=============================================================================//

package audio

import "core:log"
import "core:strings"

import "vendor:miniaudio"

audio_play_from_file :: proc(path: string) {
    new_string := strings.clone_to_cstring(path)
    err := miniaudio.engine_play_sound(&audio_system.engine, new_string, nil)
    if err != miniaudio.result.SUCCESS {
        log.error("Failed to play sound from path: %s", path)
        log.error(err)
    }
    delete(new_string)
}
