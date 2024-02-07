//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Wired
// $Create Time: 05/02/2024 17:50
//=============================================================================//

package game

import "core:log"
import "core:strings"
import "core:math/linalg"

import "render"
import "audio"
import "asset"
import "util"

MAX_MESH_COUNT :: 64

Gpu_Mesh :: struct {
    vertex_array: render.Input_Layout,
    vertex_buffer: render.Gpu_Buffer,
    index_buffer: render.Gpu_Buffer,
    index_count: i32,
    transform: linalg.Matrix4f32
}

Entity_Texture_Type :: enum {
    ALBEDO,
    NORMAL,
    METALLIC,
    ROUGHNESS,
    METALLIC_ROUGHNESS
}

Entity_Texture_Info :: struct {
    valid: b32,
    texture_path: string,
    texture_data: asset.Engine_Texture_Data,
    texture: render.Gpu_Texture
}

Renderable_Component :: struct {
    model_path: string,
    meshes: [MAX_MESH_COUNT]^Gpu_Mesh,
    mesh_count: u32,
    
    combine_metallic_roughness: b32,
    albedo_texture: Entity_Texture_Info,
    normal_texture: Entity_Texture_Info,
    metallic_texture: Entity_Texture_Info,
    roughness_texture: Entity_Texture_Info,
}

Game_Object :: struct {
    name: string,
    id: util.UUID,
    array_index: i32,

    position: [3]f32,
    rotation: [3]f32,
    scale: [3]f32,
    transform: linalg.Matrix4f32,

    has_renderable_component: b32,
    renderable_component: Renderable_Component,

    reload_mesh_next_frame: b32,
    reload_texture_next_frame: b32,
    reload_texture_type: Entity_Texture_Type,
    reload_path: ^string
}

game_object_create :: proc(id: u64 = 0) -> Game_Object {
    object: Game_Object
    
    if id == 0 {
        object.id = util.uuid_generate()
    } else {
        object.id = util.UUID(id)
    }
    object.has_renderable_component = false
    object.reload_mesh_next_frame = false

    object.position = { 0, 0, 0 }
    object.rotation = { 0, 0, 0 }
    object.scale = { 1, 1, 1 }

    object.transform[0][0] = 1
    object.transform[1][1] = 1
    object.transform[2][2] = 1
    object.transform[3][3] = 1

    return object
}

game_object_init_render :: proc(object: ^Game_Object, model_path: string) {
    if object.has_renderable_component {
        log.warn("Trying to create a renderable component on an entity that already has one!")
        return
    }

    object.has_renderable_component = true
    object.renderable_component.model_path = strings.clone(model_path)
    object.renderable_component.meshes = {}
    object.renderable_component.mesh_count = 0

    model := asset.engine_model_load(model_path)
    defer asset.engine_model_free(&model)

    for mesh in model.meshes {
        gpu_mesh: ^Gpu_Mesh = new(Gpu_Mesh)
        
        gpu_mesh.vertex_array = render.input_layout_init()
        render.input_layout_bind(&gpu_mesh.vertex_array)

        gpu_mesh.vertex_buffer = render.buffer_create(len(mesh.vertices) * size_of(asset.Gltf_Vertex), render.GpuBuffer_Type.VERTEX)
        render.buffer_bind(&gpu_mesh.vertex_buffer)
        render.buffer_upload(&gpu_mesh.vertex_buffer, len(mesh.vertices) * size_of(asset.Gltf_Vertex), &mesh.vertices[0], 0)

        gpu_mesh.index_buffer = render.buffer_create(len(mesh.indices) * size_of(u32), render.GpuBuffer_Type.INDEX)
        render.buffer_bind(&gpu_mesh.index_buffer)
        render.buffer_upload(&gpu_mesh.index_buffer, len(mesh.indices) * size_of(u32), &mesh.indices[0], 0)

        render.input_layout_push_element(0, 3, size_of(asset.Gltf_Vertex), 0, render.Input_Layout_Element.FLOAT)
        render.input_layout_push_element(1, 3, size_of(asset.Gltf_Vertex), size_of(f32) * 3, render.Input_Layout_Element.FLOAT)
        render.input_layout_push_element(2, 2, size_of(asset.Gltf_Vertex), size_of(f32) * 6, render.Input_Layout_Element.FLOAT)

        gpu_mesh.index_count = i32(len(mesh.indices))

        gpu_mesh.transform[0][0] = 1
        gpu_mesh.transform[1][1] = 1
        gpu_mesh.transform[2][2] = 1
        gpu_mesh.transform[3][3] = 1
        gpu_mesh.transform *= object.transform * mesh.transformation_matrix

        object.renderable_component.meshes[object.renderable_component.mesh_count] = gpu_mesh
        object.renderable_component.mesh_count += 1
    }
}

game_object_free_render :: proc(object: ^Game_Object) {
    if !object.has_renderable_component {
        log.warn("Trying to free a renderable component on an entity that does not have one!")
        return
    }

    for i in 0..=(object.renderable_component.mesh_count-1) {
        render.buffer_free(&object.renderable_component.meshes[i].index_buffer)
        render.buffer_free(&object.renderable_component.meshes[i].vertex_buffer)
        free(object.renderable_component.meshes[i])
    }
    delete(object.renderable_component.model_path)

    if object.renderable_component.albedo_texture.valid {
        delete(object.renderable_component.albedo_texture.texture_path)
    }

    game_object_free_texture(object, Entity_Texture_Type.ALBEDO)

    object.has_renderable_component = false
}

game_object_init_texture :: proc(object: ^Game_Object, texture_type: Entity_Texture_Type, path: string) {
    texture_to_load: ^Entity_Texture_Info
    
    #partial switch object.reload_texture_type {
        case .ALBEDO: {
            texture_to_load = &object.renderable_component.albedo_texture
        }
    }

    texture_to_load.texture_path = strings.clone(path)
    texture_to_load.texture_data = asset.engine_texture_load_simple(path)
    texture_to_load.valid = true
    defer asset.engine_texture_free(&texture_to_load.texture_data)

    texture_to_load.texture = render.texture_init(i32(texture_to_load.texture_data.handle.width), i32(texture_to_load.texture_data.handle.height), render.Texture_Format.RGBA8)
    render.texture_upload_shader_resource(&texture_to_load.texture, i32(texture_to_load.texture_data.handle.width), i32(texture_to_load.texture_data.handle.height), &texture_to_load.texture_data.handle.pixels)
}

game_object_free_texture :: proc(object: ^Game_Object, texture_type: Entity_Texture_Type) {
    texture_to_load: ^Entity_Texture_Info
    
    #partial switch object.reload_texture_type {
        case .ALBEDO: {
            texture_to_load = &object.renderable_component.albedo_texture
        }
    }

    if texture_to_load.valid {
        render.texture_destroy(&texture_to_load.texture)
    }
    texture_to_load.valid = false
}

game_object_cold_reload_mesh :: proc(object: ^Game_Object) {
    if !object.has_renderable_component {
        return
    }

    game_object_free_render(object)
    game_object_init_render(object, object.reload_path^)
    object.reload_mesh_next_frame = false
}

game_object_cold_reload_texture :: proc(object: ^Game_Object) {
    if !object.has_renderable_component {
        return
    }

    game_object_free_texture(object, object.reload_texture_type)
    game_object_init_texture(object, object.reload_texture_type, object.reload_path^)
    object.reload_texture_next_frame = false
}
