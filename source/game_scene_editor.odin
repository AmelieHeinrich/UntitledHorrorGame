//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 06/02/2024 20:17
//=============================================================================//

package game

import "imgui"
import "core:strings"
import "util"

Scene_Editor_Data :: struct {
    selected_object: ^Game_Object,
    object_selected: b32,
    selected_file: string
}

scene_editor: Scene_Editor_Data

scene_editor_init :: proc() {
    scene_editor.object_selected = false
    scene_editor.selected_file = ""
}

scene_editor_clean :: proc() {
    if len(scene_editor.selected_file) > 0 {
        delete(scene_editor.selected_file)
    }
    scene_editor.selected_file = ""
}

scene_editor_render :: proc(scene: ^Game_Scene, focused: ^b32) {
    imgui.Begin("Scene Panel", nil, {})
    focused^ = b32(imgui.IsWindowFocused({}))

    // Scene info
    imgui.Text("Editing scene: %s", scene.name)
    imgui.Text("Scene path: %s", scene.path)
    imgui.Separator()
    if imgui.Button("Save") {
        scene_serialize(scene, scene.path)
    }
    imgui.Separator()

    // Entity selection
    for i in 0..=len(scene.objects)-1 {
        obj: ^Game_Object = &scene.objects[i]
        temp := strings.clone_to_cstring(obj.name)
        if imgui.Selectable(temp) {
            scene_editor.selected_object = obj
            scene_editor.object_selected = true
        }
        delete(temp)
    }

    // Draw data
    if scene_editor.object_selected {
        imgui.Separator()
        imgui.Text("Name: %s", scene_editor.selected_object.name)
        
        imgui.Separator()
        imgui.DragFloat3("Position", &scene_editor.selected_object.position)
        imgui.DragFloat3("Rotation", &scene_editor.selected_object.rotation)
        imgui.DragFloat3("Scale", &scene_editor.selected_object.scale)
        
        if scene_editor.selected_object.has_renderable_component {
            imgui.Separator()
            imgui.Text("Model: %s", scene_editor.selected_object.renderable_component.model_path)
            if imgui.Button("Select Mesh...") {
                scene_editor.selected_file = util.file_dialog_open(game.window.window, "")
                if len(scene_editor.selected_file) > 0 {
                    scene_editor.selected_object.reload_mesh_next_frame = true
                    scene_editor.selected_object.reload_path = &scene_editor.selected_file
                }
            }
            imgui.Separator()

            imgui.Text("Albedo Texture: %s", scene_editor.selected_object.renderable_component.albedo_texture.texture_path)
            imgui.SameLine()
            if imgui.Button("Change") {
                scene_editor.selected_file = util.file_dialog_open(game.window.window, "")
                if len(scene_editor.selected_file) > 0 {
                    scene_editor.selected_object.reload_texture_next_frame = true
                    scene_editor.selected_object.reload_texture_type = Entity_Texture_Type.ALBEDO
                    scene_editor.selected_object.reload_path = &scene_editor.selected_file
                }
            }
        }
    }

    imgui.End()
}
