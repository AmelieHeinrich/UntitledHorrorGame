//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 16/01/2024 15:44
//=============================================================================//

package game

import "core:log"
import "core:math"
import "core:bytes"
import gl "vendor:OpenGL"

Shader_Module :: struct {
    program: u32,
    uniforms: gl.Uniforms,
}

GpuBuffer_Type :: enum {
    VERTEX,
    INDEX
}

Gpu_Buffer :: struct {
    id: u32,
    type: GpuBuffer_Type,
}

Input_Layout_Element :: enum {
    FLOAT,
    INT
}

Input_Layout :: struct {
    id: u32
}

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

input_element_to_gl :: proc(element: Input_Layout_Element) -> u32 {
    switch element {
        case .FLOAT:
            return gl.FLOAT
        case .INT:
            return gl.INT
    }
    return gl.FLOAT
}

shader_create_standard :: proc(vertex: string, fragment: string) -> Shader_Module {
    module: Shader_Module
    
    program, ok := gl.load_shaders_file(vertex, fragment)
    if !ok {
        log.errorf("Failed to create standard shader from path %s and %s", vertex, fragment)
        module.program = 0
        return module;
    }
    module.program = program
    module.uniforms = gl.get_uniforms_from_program(module.program)
    return module
}

shader_create_compute :: proc(compute: string) -> Shader_Module {
    module: Shader_Module

    program, ok := gl.load_compute_file(compute)
    if !ok {
        log.errorf("Failed to create compute shader from path %s", compute)
        module.program = 0
        return module
    }
    module.program = program
    module.uniforms = gl.get_uniforms_from_program(module.program)
    return module
}

shader_bind :: proc(module: ^Shader_Module) {
    gl.UseProgram(module.program)
}

shader_unbind :: proc() {
    gl.UseProgram(0)
}

shader_destroy :: proc(module: ^Shader_Module) {
    gl.DeleteProgram(module.program)
}

shader_uniform_float :: proc(module: ^Shader_Module, name: string, val: f32) {
    gl.Uniform1f(module.uniforms[name].location, val)
}

shader_uniform_float2 :: proc(module: ^Shader_Module, name: string, val: [2]f32) {
    gl.Uniform2f(module.uniforms[name].location, val[0], val[1])
}

shader_uniform_float3 :: proc(module: ^Shader_Module, name: string, val: [3]f32) {
    gl.Uniform3f(module.uniforms[name].location, val[0], val[1], val[2])
}

shader_uniform_float4 :: proc(module: ^Shader_Module, name: string, val: [4]f32) {
    gl.Uniform4f(module.uniforms[name].location, val[0], val[1], val[2], val[3])
}

shader_uniform_mat4 :: proc(module: ^Shader_Module, name: string, val: [^]f32) {
    gl.UniformMatrix4fv(module.uniforms[name].location, 1, false, val)
}

shader_uniform_int :: proc(module: ^Shader_Module, name: string, val: i32) {
    gl.Uniform1i(module.uniforms[name].location, val)
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

input_layout_init :: proc() -> Input_Layout {
    layout: Input_Layout
    gl.GenVertexArrays(1, &layout.id)
    return layout
}

input_layout_destroy :: proc(layout: ^Input_Layout) {
    gl.DeleteVertexArrays(1, &layout.id)
}

input_layout_bind :: proc(layout: ^Input_Layout) {
    gl.BindVertexArray(layout.id)
}

input_layout_unbind :: proc() {
    gl.BindVertexArray(0)
}

input_layout_push_element :: proc(index: u32, attribute_size: i32, stride: i32, offset: uintptr, attribute_type: Input_Layout_Element) {
    gl.EnableVertexAttribArray(index)
    gl.VertexAttribPointer(index, attribute_size, input_element_to_gl(attribute_type), gl.FALSE, stride, offset)
}

texture_init :: proc(width: i32, height: i32, format: Texture_Format) -> Gpu_Texture {
    texture: Gpu_Texture
    texture.width = width
    texture.height = height
    texture.format = format
    gl.GenTextures(1, &texture.id)
    return texture;
}

texture_bind_shader_resource :: proc(texture: ^Gpu_Texture, slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, texture.id)
}

texture_unbind_shader_resource :: proc(slot: u32) {
    gl.ActiveTexture(gl.TEXTURE0 + slot)
    gl.BindTexture(gl.TEXTURE_2D, 0)
}

texture_upload_shader_resource :: proc(texture: ^Gpu_Texture, image: ^Engine_Texture_Data) {
    texture.width = i32(image.handle.width)
    texture.height = i32(image.handle.height)

    texture_bytes := bytes.buffer_to_bytes(&image.handle.pixels);

    gl.BindTexture(gl.TEXTURE_2D, texture.id)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.TexStorage2D(gl.TEXTURE_2D, 1, texture_format_to_gl(texture.format), texture.width, texture.height)
	gl.TexSubImage2D(gl.TEXTURE_2D, 0, 0, 0, texture.width, texture.height, gl.RGBA, gl.UNSIGNED_BYTE, &texture_bytes[0])
}

texture_destroy :: proc(texture: ^Gpu_Texture) {
    gl.DeleteTextures(1, &texture.id);
}

context_clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

context_clear_color :: proc(r: f32, g: f32, b: f32, a: f32) {
    gl.ClearColor(r, g, b, a)
}

context_viewport :: proc(width: i32, height: i32, x: i32 = 0, y: i32 = 0) {
    gl.Viewport(x, y, width, height)
}

context_draw :: proc(start: i32, count: i32) {
    gl.DrawArrays(gl.TRIANGLES, start, count)
}

context_draw_indexed :: proc(count: i32) {
    gl.DrawElements(gl.TRIANGLES, count, gl.UNSIGNED_INT, nil)
}
