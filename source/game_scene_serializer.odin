//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 06/02/2024 16:11
//=============================================================================//

package game

import "core:os"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:path/slashpath"
import "core:math/linalg"
import "core:encoding/json"

Serializable_Entity :: struct {
    name: string,
    position: [3]f64,
    rotation: [3]f64,
    scale: [3]f64,
    renderable: b32,
    modelPath: string
}

Serializable_Scene :: struct {
    sceneName: string,
    entities: [dynamic]Serializable_Entity
}

scene_deserialize :: proc(path: string) -> Game_Scene {
    data, ok := os.read_entire_file_from_filename(path)
    if !ok {
        log.errorf("Failed to load scene file of path %s", path)
        return {}
    }
    defer delete(data)

    json_data, err := json.parse(data)
    if err != .None {
        log.errorf("Failed to parse json data in file %s", path)
        log.error(err)
        return {}
    }
    defer json.destroy_value(json_data)
    log.infof("Parsed scene file at %s", path)

    root := json_data.(json.Object)
    entities := root["entities"].(json.Array)

    ret_scene := scene_create()
    ret_scene.name = strings.clone(root["sceneName"].(json.String))
    ret_scene.path = strings.clone(path)

    for i in 0..=len(entities)-1 {
        game_object := scene_new_game_object(&ret_scene)
    
        entity_root := entities[i].(json.Object)
        position_root := entity_root["position"].(json.Array)
        rotation_root := entity_root["rotation"].(json.Array)
        scale_root := entity_root["scale"].(json.Array)
        
        game_object.name = strings.clone(entity_root["name"].(json.String))

        game_object.position.x = f32(position_root[0].(json.Float))
        game_object.position.y = f32(position_root[1].(json.Float))
        game_object.position.z = f32(position_root[2].(json.Float))

        game_object.rotation.x = f32(rotation_root[0].(json.Float))
        game_object.rotation.y = f32(rotation_root[1].(json.Float))
        game_object.rotation.z = f32(rotation_root[2].(json.Float))

        game_object.scale.x = f32(scale_root[0].(json.Float))
        game_object.scale.y = f32(scale_root[1].(json.Float))
        game_object.scale.z = f32(scale_root[2].(json.Float))

        // Recreate transform
        game_object.transform *= linalg.matrix4_translate_f32({ game_object.position.x, game_object.position.y, game_object.position.z })
        if game_object.rotation.x != 0 {
            game_object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(game_object.rotation.x), {1, 0, 0})
        }
        if game_object.rotation.y != 0 {
            game_object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(game_object.rotation.y), {0, 1, 0})
        }
        if game_object.rotation.z != 0 {
            game_object.transform *= linalg.matrix4_rotate_f32(linalg.to_radians(game_object.rotation.z), {0, 0, 1})
        }
        game_object.transform *= linalg.matrix4_scale_f32({ game_object.scale.x, game_object.scale.y, game_object.scale.y })

        // Renderable
        if entity_root["renderable"].(json.Boolean) {
            game_object_init_render(game_object, entity_root["modelPath"].(json.String))
        }
    }

    return ret_scene
}

scene_serialize :: proc(scene: ^Game_Scene, save_path: string = "") {
    path_to_save_as := save_path
    if save_path != "" {
        path_to_save_as = scene.path
    }

    write_scene: Serializable_Scene
    write_scene.sceneName = scene.name
    write_scene.entities = make([dynamic]Serializable_Entity)
    defer delete(write_scene.entities)
    
    for obj in scene.objects {
        serializable_entity: Serializable_Entity
        serializable_entity.name = obj.name

        serializable_entity.position.x = f64(obj.position.x)
        serializable_entity.position.y = f64(obj.position.y)
        serializable_entity.position.z = f64(obj.position.z)

        serializable_entity.rotation.x = f64(obj.rotation.x)
        serializable_entity.rotation.y = f64(obj.rotation.y)
        serializable_entity.rotation.z = f64(obj.rotation.z)

        serializable_entity.scale.x = f64(obj.scale.x)
        serializable_entity.scale.y = f64(obj.scale.y)
        serializable_entity.scale.z = f64(obj.scale.z)

        serializable_entity.renderable = obj.has_renderable_component
        serializable_entity.modelPath = obj.renderable_component.model_path

        append(&write_scene.entities, serializable_entity)
    }

    opt: json.Marshal_Options
    opt.pretty = true

    bytes, err := json.marshal(write_scene, opt)
    if err != nil {
        log.errorf("Failed to convert json data back to bytes")
        log.error(err)
        return
    }
    defer delete(bytes)

    ok := os.write_entire_file(save_path, bytes)
    if !ok {
        log.errorf("Failed to write json string to file %s", save_path)
    }
}
