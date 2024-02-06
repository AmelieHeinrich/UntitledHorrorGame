//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 20/01/2024 16:27
//=============================================================================//

package game

import "core:math"
import "core:math/linalg"

import "vendor:sdl2"

import "base"

CAMERA_DEFAULT_YAW :: -90
CAMERA_DEFAULT_PITCH :: 0
CAMERA_DEFAULT_SPEED :: 1
CAMERA_DEFAULT_SENSITIVITY :: 0.1
CAMERA_DEFAULT_FRICTION :: 10
CAMERA_DEFAULT_ACCELERATION :: 20
CAMERA_DEFAULT_MAX_VELOCITY :: 15
CAMERA_DEFAULT_FOV :: 90

Free_Camera :: struct {
    // Rotate info
    yaw: f32,
    pitch: f32,
    fov: f32,

    // World info
    position: linalg.Vector3f32,
    front: linalg.Vector3f32,
    up: linalg.Vector3f32,
    right: linalg.Vector3f32,
    world_up: linalg.Vector3f32,

    // Input stuff
    mouse_pos: [2]i32,
    first_mouse: bool,

    // Matrices
    view: linalg.Matrix4x4f32,
    projection: linalg.Matrix4x4f32,
    view_proj: linalg.Matrix4x4f32,

    // Movement info
    acceleration: f32,
    friction: f32,
    velocity: linalg.Vector3f32,
    max_velocity: f32,

    // Miscallaneous for aspect ratio
    width: i32,
    height: i32
}

free_cam_init :: proc() -> Free_Camera {
    cam: Free_Camera
    cam.up[1] = -1.0
    cam.front[2] = -1.0
    cam.world_up[1] = 1.0
    cam.position[2] = 2.0
    cam.yaw = CAMERA_DEFAULT_YAW
    cam.pitch = CAMERA_DEFAULT_PITCH
    cam.friction = CAMERA_DEFAULT_FRICTION
    cam.acceleration = CAMERA_DEFAULT_ACCELERATION
    cam.max_velocity = CAMERA_DEFAULT_MAX_VELOCITY
    cam.fov = CAMERA_DEFAULT_FOV
    free_cam_update_vectors(&cam)
    return cam
}

free_cam_update_vectors :: proc(cam: ^Free_Camera) {
    front: linalg.Vector3f32
    front[0] = math.cos(math.to_radians(cam.yaw)) * math.cos(math.to_radians(cam.pitch))
    front[1] = math.sin(math.to_radians(cam.pitch))
    front[2] = math.sin(math.to_radians(cam.yaw)) * math.cos(math.to_radians(cam.pitch))
    cam.front = linalg.normalize(front)
    cam.right = linalg.normalize(linalg.cross(cam.front, cam.world_up))
    cam.up = linalg.normalize(linalg.cross(cam.right, cam.front))
}

free_cam_update :: proc(cam: ^Free_Camera, dt: f32) {
    cam.width = game.window.width
    cam.height = game.window.height

    mouse_pos := base.input_system_get_mouse_position()

    cam.mouse_pos[0] = mouse_pos[0]
    cam.mouse_pos[1] = mouse_pos[1]

    cam.view = linalg.matrix4_look_at(cam.position, cam.position + cam.front, cam.world_up)
    cam.projection = linalg.matrix4_perspective(cam.fov, f32(cam.width) / f32(cam.height), 0.05, 10000)
    cam.view_proj = cam.view * cam.projection
}

free_cam_input :: proc(cam: ^Free_Camera, dt: f32) {
    speed_multiplier := cam.acceleration * dt
    if base.input_system_is_key_pressed(sdl2.Keycode.Z) {
        cam.velocity += cam.front * speed_multiplier
    }
    else if base.input_system_is_key_pressed(sdl2.Keycode.S) {
        cam.velocity -= cam.front * speed_multiplier
    }
    if base.input_system_is_key_pressed(sdl2.Keycode.Q) {
        cam.velocity -= cam.right * speed_multiplier
    }
    else if base.input_system_is_key_pressed(sdl2.Keycode.D) {
        cam.velocity += cam.right * speed_multiplier
    }

    friction_multiplier := 1.0 / (1.0 + (cam.friction * dt))
    cam.velocity = cam.velocity * friction_multiplier

    vec_length := linalg.length(cam.velocity)
    if vec_length > cam.max_velocity {
        cam.velocity = linalg.normalize(cam.velocity) * cam.max_velocity
    }
    cam.position += cam.velocity * dt

    mouse := base.input_system_get_mouse_position()

    dx := f32(mouse[0] - cam.mouse_pos[0]) * CAMERA_DEFAULT_SENSITIVITY
    dy := f32(mouse[1] - cam.mouse_pos[1]) * CAMERA_DEFAULT_SENSITIVITY

    if base.input_system_is_button_pressed(sdl2.BUTTON_LEFT) {
        cam.yaw += dx
        cam.pitch -= dy
    }

    free_cam_update_vectors(cam)
}

free_cam_resize :: proc(cam: ^Free_Camera, width: i32, height: i32) {
    cam.width = width
    cam.height = height
    free_cam_update_vectors(cam)
} 
