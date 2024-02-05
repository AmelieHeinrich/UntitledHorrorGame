//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Untitled Horror Game
// $Create Time: 22/01/2024 19:25
//=============================================================================//

package render

import "core:log"
import gl "vendor:OpenGL"

Shader_Module :: struct {
    program: u32,
    uniforms: gl.Uniforms,
}

shader_create_standard :: proc(vertex: string, fragment: string) -> Shader_Module {
    module: Shader_Module
    
    program, ok := gl.load_shaders_file(vertex, fragment)
    if !ok {
        log.errorf("Failed to create standard shader from path %s and %s", vertex, fragment)
        module.program = 0
        return module
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
    for uniform in module.uniforms {
        delete(uniform)
    }
    delete(module.uniforms)
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
