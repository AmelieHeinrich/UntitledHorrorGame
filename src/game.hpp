/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 01:06:06
 */

#pragma once

#include <memory>

#include "asset/image.hpp"
#include "asset/model.hpp"

#include "core/core.hpp"
#include "core/logger.hpp"
#include "core/window.hpp"
#include "core/file_system.hpp"
#include "core/input_system.hpp"
#include "core/timer.hpp"

#include "renderer/context.hpp"
#include "renderer/texture.hpp"
#include "renderer/shader.hpp"
#include "renderer/graphics_pipeline.hpp"
#include "renderer/compute_pipeline.hpp"
#include "renderer/sampler.hpp"
#include "renderer/buffer.hpp"

#include "game/free_camera.hpp"
#include "game/game_object.hpp"
#include "game/scene.hpp"
#include "game/scene_renderer.hpp"
#include "game/scene_serializer.hpp"
#include "game/scene_editor.hpp"
#include "game/reload_queue.hpp"

#include "util/file_dialog.hpp"

struct GameState
{
    nlohmann::json config;

    i32 width;
    i32 height;
    Ref<Window> window;

    Ref<SceneRenderer> sceneRenderer;
    bool editorFocused;

    f64 lastFrame;
};

extern GameState state;
