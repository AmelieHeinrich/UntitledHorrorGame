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
#include "core/memory_tracker.hpp"

#include "game/free_camera.hpp"
#include "game/game_object.hpp"
#include "game/scene.hpp"
#include "game/scene_serializer.hpp"
#include "game/scene_editor.hpp"
#include "game/reload_queue.hpp"

#include "physics/physics_system.hpp"

#include "renderer/render_graph.hpp"
#include "renderer/render_node.hpp"
#include "renderer/nodes/forward_node.hpp"
#include "renderer/nodes/fxaa_node.hpp"
#include "renderer/nodes/composite_node.hpp"

#include "rhi/context.hpp"
#include "rhi/texture.hpp"
#include "rhi/shader.hpp"
#include "rhi/graphics_pipeline.hpp"
#include "rhi/compute_pipeline.hpp"
#include "rhi/sampler.hpp"
#include "rhi/buffer.hpp"

#include "util/file_dialog.hpp"

struct GameState
{
    nlohmann::json config;

    i32 width;
    i32 height;
    Ref<Window> window;

    Ref<RenderGraph> graph;
    bool editorFocused;
    bool fullscreen = false;

    f64 lastFrame;
};

extern GameState state;
