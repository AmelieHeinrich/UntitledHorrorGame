//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 05/02/2024 17:41
//=============================================================================//

package game

import "render"
import "asset"
import "audio"

Game_Scene :: struct {
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
    if len(scene.objects) == 0 {
        return
    }

    for i in 0..=len(scene.objects)-1 {
        if scene.objects[i].has_renderable_component {
            game_object_free_render(&scene.objects[i])
        }
    }
}

scene_update :: proc(scene: ^Game_Scene, dt: f32) {
    free_cam_input(&scene.camera, dt)
    free_cam_update(&scene.camera, dt)

    audio.audio_system_set_listener_info(scene.camera.position, scene.camera.front)
}
