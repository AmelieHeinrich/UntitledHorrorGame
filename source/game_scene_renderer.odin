//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Wired
// $Create Time: 05/02/2024 18:25
//=============================================================================//

package game

import "render"
import "asset"

import "core:math/linalg"

Scene_Renderer :: struct {
    forward_shader: render.Shader_Module,
    default_texture: render.Gpu_Texture
}

scene_renderer_init :: proc() -> Scene_Renderer {
    scene_renderer: Scene_Renderer

    scene_renderer.forward_shader = render.shader_create_standard("gamedata/shaders/geometry_vtx.glsl", "gamedata/shaders/geometry_frg.glsl")

    default_texture_file := asset.engine_texture_load_simple("gamedata/assets/textures/default.png")
    defer asset.engine_texture_free(&default_texture_file)

    scene_renderer.default_texture = render.texture_init(i32(default_texture_file.handle.width), i32(default_texture_file.handle.height), render.Texture_Format.RGBA8)
    render.texture_upload_shader_resource(&scene_renderer.default_texture, i32(default_texture_file.handle.width), i32(default_texture_file.handle.height), &default_texture_file.handle.pixels)

    return scene_renderer
}

scene_renderer_render :: proc(renderer: ^Scene_Renderer, scene: ^Game_Scene) {
    render.shader_bind(&renderer.forward_shader)
    render.shader_uniform_mat4(&renderer.forward_shader, "proj", &scene.camera.projection[0][0])
    render.shader_uniform_mat4(&renderer.forward_shader, "view", &scene.camera.view[0][0])

    for object in scene.objects {
        if object.has_renderable_component {
            for j in 0..=(object.renderable_component.mesh_count-1) {
                local_matrix := object.transform * object.renderable_component.meshes[j].transform

                albedo_texture := renderer.default_texture
                if object.renderable_component.albedo_texture.valid {
                    albedo_texture = object.renderable_component.albedo_texture.texture
                }

                render.texture_bind_shader_resource(&albedo_texture, 0)
                render.shader_uniform_int(&renderer.forward_shader, "diffuseTexture", 0)
                render.shader_uniform_mat4(&renderer.forward_shader, "model", &local_matrix[0][0])
                render.input_layout_bind(&object.renderable_component.meshes[j].vertex_array)
                render.buffer_bind(&object.renderable_component.meshes[j].vertex_buffer)
                render.buffer_bind(&object.renderable_component.meshes[j].index_buffer)
                render.context_draw_indexed(object.renderable_component.meshes[j].index_count)
            }
        }
    }
}

scene_renderer_free :: proc(renderer: ^Scene_Renderer) {
    render.texture_destroy(&renderer.default_texture)
    render.shader_destroy(&renderer.forward_shader)
}
