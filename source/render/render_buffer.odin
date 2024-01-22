//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 22/01/2024 19:26
//=============================================================================//

package render

import gl "vendor:OpenGL"

GpuBuffer_Type :: enum {
    VERTEX,
    INDEX
}

Gpu_Buffer :: struct {
    id: u32,
    type: GpuBuffer_Type,
}

buffer_create :: proc(size: int, type: GpuBuffer_Type) -> Gpu_Buffer {
    buffer: Gpu_Buffer
    buffer.type = type
    
    gl.GenBuffers(1, &buffer.id)

    buffer_bind(&buffer)
    switch buffer.type {
        case .VERTEX:
            gl.BufferData(gl.ARRAY_BUFFER, size, nil, gl.DYNAMIC_DRAW)
            break
        case .INDEX:
            gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size, nil, gl.DYNAMIC_DRAW)
            break
    }
    buffer_unbind(type)
    return buffer
}

buffer_free :: proc(buffer: ^Gpu_Buffer) {
    gl.DeleteBuffers(1, &buffer.id)
}

buffer_upload :: proc(buffer: ^Gpu_Buffer, size: int, data: rawptr, offset: int) {
    switch buffer.type {
        case .VERTEX:
            gl.BufferSubData(gl.ARRAY_BUFFER, offset, size, data)
            break
        case .INDEX:
            gl.BufferSubData(gl.ELEMENT_ARRAY_BUFFER, offset, size, data)
            break
    }
}

buffer_bind :: proc(buffer: ^Gpu_Buffer) {
    switch buffer.type {
        case .VERTEX:
            gl.BindBuffer(gl.ARRAY_BUFFER, buffer.id)
            break
        case .INDEX:
            gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.id)
            break
    }
}

buffer_unbind :: proc(type: GpuBuffer_Type) {
    switch type {
        case .VERTEX:
            gl.BindBuffer(gl.ARRAY_BUFFER, 0)
            break
        case .INDEX:
            gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
            break
    }
}

