//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Wired
// $Create Time: 05/02/2024 18:25
//=============================================================================//

package game

import "render"
import "asset"

Scene_Renderer :: struct {
    forward_shader: render.Shader_Module,
}

scene_renderer_init :: proc() -> Scene_Renderer {
    scene_renderer: Scene_Renderer

    scene_renderer.forward_shader = render.shader_create_standard("gamedata/shaders/geometry_vtx.glsl", "gamedata/shaders/geometry_frg.glsl")

    return scene_renderer
}

scene_renderer_render :: proc(renderer: ^Scene_Renderer, scene: ^Game_Scene) {
    render.shader_bind(&renderer.forward_shader)
    render.shader_uniform_mat4(&renderer.forward_shader, "proj", &scene.camera.projection[0][0])
    render.shader_uniform_mat4(&renderer.forward_shader, "view", &scene.camera.view[0][0])

    for object in scene.objects {
        if object.has_renderable_component {
            for j in 0..=(object.renderable_component.mesh_count-1) {
                render.shader_uniform_mat4(&renderer.forward_shader, "model", &object.renderable_component.meshes[j].transform[0][0])
                render.input_layout_bind(&object.renderable_component.meshes[j].vertex_array)
                render.buffer_bind(&object.renderable_component.meshes[j].vertex_buffer)
                render.buffer_bind(&object.renderable_component.meshes[j].index_buffer)
                render.context_draw_indexed(object.renderable_component.meshes[j].index_count)
            }
        }
    }
}

scene_renderer_free :: proc(renderer: ^Scene_Renderer) {
    render.shader_destroy(&renderer.forward_shader)
}
