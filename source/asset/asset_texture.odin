//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 18/01/2024 10:51
//=============================================================================//

package asset

import "core:image"
import "core:image/png"
import "core:image/netpbm"
import "core:image/qoi"
import "core:image/tga"
import "core:log"

Engine_Texture_Data :: struct {
    path: string,
    handle: ^image.Image
}

// Loads texture data from a file. Need to implement an upgraded version that takes a file handle so we can implement multithreading/streaming
engine_texture_load_simple :: proc(path: string) -> Engine_Texture_Data {
    handle: Engine_Texture_Data

    img, err := image.load_from_file(path, { .alpha_add_if_missing })
    if err != nil {
        log.errorf("Failed to load image %s!", path)
        log.error(err)
    }
    handle.path = path
    handle.handle = img
    return handle
}

engine_texture_free :: proc(texture: ^Engine_Texture_Data) {
    image.destroy(texture.handle)
}
