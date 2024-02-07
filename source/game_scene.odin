//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 05/02/2024 17:41
//=============================================================================//

package game

import "render"
import "asset"
import "audio"
import "imgui"

import "core:math/linalg"

Game_Scene :: struct {
    name: string,
    path: string,
    camera: Free_Camera,
    objects: [dynamic]Game_Object
}

scene_create :: proc() -> Game_Scene {
    scene: Game_Scene

    scene.objects = make([dynamic]Game_Object)
    scene.camera = free_cam_init()
    
    return scene
}

scene_new_game_object :: proc(scene: ^Game_Scene) -> ^Game_Object {
    object := game_object_create()
    object.array_index = i32(len(scene.objects)) + 1
    append(&scene.objects, object)
    return &scene.objects[object.array_index - 1]
}

scene_remove_and_delete_game_object :: proc(scene: ^Game_Scene, object: ^Game_Object) {
    if object.has_renderable_component {
        game_object_free_render(object)
    }
    ordered_remove(&scene.objects, int(object.array_index - 1))
}

scene_remove_game_object :: proc(scene: ^Game_Scene, object: ^Game_Object) {
    ordered_remove(&scene.objects, int(object.array_index - 1))
}

scene_add_game_object :: proc(scene: ^Game_Scene, object: ^Game_Object) {
    append(&scene.objects, object^)
}

scene_free :: proc(scene: ^Game_Scene) {

    for i in 0..=len(scene.objects)-1 {
        if len(scene.objects) == 0 {
            break
        }
        delete(scene.objects[i].name)
        if scene.objects[i].has_renderable_component {
            game_object_free_render(&scene.objects[i])
        }
    }
    delete(scene.name)
    delete(scene.path)
    delete(scene.objects)
}

scene_update :: proc(scene: ^Game_Scene, dt: f32, update_input: b32) {
    if update_input {
        free_cam_input(&scene.camera, dt)
    }
    free_cam_update(&scene.camera, dt)

    // Update transforms
    for i in 0..=len(scene.objects)-1 {
        object: ^Game_Object = &scene.objects[i]

        object.transform = linalg.matrix4_translate_f32({object.position.x, object.position.y, object.position.z})
        if object.rotation.x != 0 {
            object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(object.rotation.x), {1, 0, 0})
        }
        if object.rotation.y != 0 {
            object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(object.rotation.y), {0, 1, 0})
        }
        if object.rotation.z != 0 {
            object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(object.rotation.z), {0, 0, 1})
        }
        object.transform *= linalg.matrix4_scale_f32({object.scale.x, object.scale.y, object.scale.z})
    }

    audio.audio_system_set_listener_info(scene.camera.position, scene.camera.front)
}

scene_process_reload :: proc(scene: ^Game_Scene) {
    for i in 0..=len(scene.objects)-1 {
        object: ^Game_Object = &scene.objects[i]

        if object.reload_mesh_next_frame {
            game_object_cold_reload_mesh(object)
        }
        if object.reload_texture_next_frame {
            game_object_cold_reload_texture(object)
        }
    }
}
