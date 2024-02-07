//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 22/01/2024 19:33
//=============================================================================//

package asset

import "core:math/linalg"
import "core:strings"
import "core:log"
import "core:c"
import "core:fmt"

import "vendor:cgltf"

Gltf_Vertex :: struct {
    position: [3]f32,
    normals: [3]f32,
    uv: [2]f32,
}

Mesh_Data :: struct {
    vertices: [dynamic]Gltf_Vertex,
    indices: [dynamic]u32,

    translation: linalg.Vector3f32,
    rotation: linalg.Quaternionf32,
    scale: linalg.Vector3f32,
    transformation_matrix: linalg.Matrix4f32
}

Engine_Model :: struct {
    meshes: [dynamic]Mesh_Data,
    path: string,
}

@(private)
process_primitive :: proc(data: ^Mesh_Data, primitive: cgltf.primitive) {
    if (primitive.type != cgltf.primitive_type.triangles) {
        log.warn("Found GLTF primitive that isn't of type triangles. Discarding...")
        return
    }

    pos_attribute: cgltf.attribute
    found_pos := false

    uv_attribute: cgltf.attribute
    found_uv := false

    norm_attribute: cgltf.attribute
    found_norm := false

    for attribute in primitive.attributes {
        name_string := string(attribute.name)
        if strings.contains(name_string, "POSITION") {
            pos_attribute = attribute
            found_pos = true
        }
        if strings.contains(name_string, "TEXCOORD_0") {
            uv_attribute = attribute
            found_uv = true
        }
        if strings.contains(name_string, "NORMAL") {
            norm_attribute = attribute
            found_norm = true
        }
    }

    assert(found_pos && found_uv && found_norm, "Invalid model data! It must contains position, UV and normal attributes in its respective GLTF file/binary.")

    vertex_count := pos_attribute.data.count
    data.vertices = make([dynamic]Gltf_Vertex)

    for i: uint = 0; i < vertex_count; i += 1 {
        vertex: Gltf_Vertex
        append(&data.vertices, vertex)
    }

    for i: uint = 0; i < vertex_count; i += 1 {
        // Vertices
        if !cgltf.accessor_read_float(pos_attribute.data, i, &data.vertices[i].position[0], 4) {
            log.error("Failed to read position accessor x component!")
        }

        // Normals
        if !cgltf.accessor_read_float(norm_attribute.data, i, &data.vertices[i].normals[0], 4) {
            log.error("Failed to read normal accessor x component!")
        }
        // UVs
        if !cgltf.accessor_read_float(uv_attribute.data, i, &data.vertices[i].uv[0], 4) {
            log.error("Failed to read uv accessor x component!")
        }
    }

    index_count := primitive.indices.count
    data.indices = make([dynamic]u32)

    for i: uint = 0; i < index_count; i += 1 {
        index := cgltf.accessor_read_index(primitive.indices, i)
        append(&data.indices, u32(index))
    }
}

@(private)
process_node :: proc(node: ^cgltf.node, model: ^Engine_Model) {
    if node.mesh != nil {
        data: Mesh_Data
        data.transformation_matrix[0][0] = 1.0
        data.transformation_matrix[1][1] = 1.0
        data.transformation_matrix[2][2] = 1.0
        data.transformation_matrix[3][3] = 1.0

        if node.has_translation {
            data.translation.x = node.translation[0]
            data.translation.y = node.translation[1]
            data.translation.z = node.translation[2]
            data.transformation_matrix *= linalg.matrix4_translate_f32(data.translation)
        }

        if node.has_rotation {
            data.rotation.x = node.rotation[3]
            data.rotation.y = node.rotation[2]
            data.rotation.z = node.rotation[1]
            data.rotation.w = node.rotation[0]
            data.transformation_matrix *= linalg.matrix4_from_quaternion_f32(data.rotation)
        }

        if node.has_scale {
            data.scale.x = node.scale[0]
            data.scale.y = node.scale[1]
            data.scale.z = node.scale[2]
            data.transformation_matrix *= linalg.matrix4_scale_f32(data.scale);
        }

        for p in node.mesh.primitives {
            process_primitive(&data, p);
            append(&model.meshes, data);
        }
    }

    for child in node.children {
        process_node(child, model)
    }
}

engine_model_load :: proc(path: string) -> Engine_Model {
    model: Engine_Model

    options: cgltf.options

    safe_path := strings.clone_to_cstring(path)
    defer delete(safe_path)

    data, res := cgltf.parse_file(options, safe_path)
    if res != cgltf.result.success {
        log.errorf("Failed to parsed gltf file %s", safe_path)
        log.error(res)
    } else {
        log.debugf("Parsed gltf file %s", safe_path)
    }
    defer cgltf.free(data)

    res = cgltf.load_buffers(options, data, safe_path)
    if res != cgltf.result.success {
        log.errorf("Failed to load gltf buffers from file %s", safe_path)
        log.error(res)
    } else {
        log.debugf("Loaded gltf buffers from file %s", safe_path)
    }

    scene := data.scene

    for node in scene.nodes {
        process_node(node, &model)
    }

    return model
}

engine_model_free :: proc(model: ^Engine_Model) {
    for mesh in model.meshes {
        delete(mesh.vertices)
        delete(mesh.indices)
    }
    delete(model.meshes)
}
