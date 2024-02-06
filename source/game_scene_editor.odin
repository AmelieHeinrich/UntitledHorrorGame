//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 06/02/2024 20:17
//=============================================================================//

package game

import "imgui"
import "core:strings"

Scene_Editor_Data :: struct {
    selected_object: ^Game_Object,
    object_selected: b32
}

scene_editor: Scene_Editor_Data

scene_editor_init :: proc() {
    scene_editor.object_selected = false
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
        imgui.DragFloat3("Position", &scene_editor.selected_object.position)
        imgui.DragFloat3("Rotation", &scene_editor.selected_object.rotation)
        imgui.DragFloat3("Scale", &scene_editor.selected_object.scale)
    }


    imgui.End()
}
