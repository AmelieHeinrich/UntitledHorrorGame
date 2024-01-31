//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 22/01/2024 19:24
//=============================================================================//

package render

import "core:bytes"
import gl "vendor:OpenGL"

Texture_Format :: enum {
    RGBA8,
    RGBA16F,
    RGBA32F,
    D32S8F
}

Gpu_Texture :: struct {
    id: u32,
    width: i32,
    height: i32,
    format: Texture_Format
    // TODO: Layout (color attachment? depth attachment? shader resource?)
}

texture_format_to_gl :: proc(format: Texture_Format) -> u32 {
    switch format {
        case .RGBA8:
            return gl.RGBA8
        case .RGBA16F:
            return gl.RGBA16F
        case .RGBA32F:
            return gl.RGBA32F
        case .D32S8F:
            return gl.DEPTH32F_STENCIL8
    }
    return gl.INVALID_ENUM
}

texture_init :: proc(width: i32, height: i32, format: Texture_Format) -> Gpu_Texture {
    texture: Gpu_Texture
    texture.width = width
    texture.height = height
    texture.format = format
    gl.GenTextures(1, &texture.id)
    return texture
}

texture_bind_shader_resource :: proc(texture: ^Gpu_Texture, slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, texture.id)
}

texture_unbind_shader_resource :: proc(slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, 0)
}

texture_upload_shader_resource :: proc(texture: ^Gpu_Texture, width: i32, height: i32, pixels: ^bytes.Buffer) {
    texture.width = width
    texture.height = height

    texture_bytes := bytes.buffer_to_bytes(pixels)

    gl.BindTexture(gl.TEXTURE_2D, texture.id)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexStorage2D(gl.TEXTURE_2D, 1, texture_format_to_gl(texture.format), texture.width, texture.height)
	gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, texture.width, texture.height, gl.RGBA, gl.UNSIGNED_BYTE, &texture_bytes[0])
}

texture_destroy :: proc(texture: ^Gpu_Texture) {
    gl.DeleteTextures(1, &texture.id)
}
