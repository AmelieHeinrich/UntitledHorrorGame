/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-18 01:27:43
 */

#include "game.hpp"

#include <glm/glm.hpp>
#include <imgui/imgui.h>

GameState state;

struct caca
{
    glm::mat4 view;
    glm::mat4 proj;
    glm::mat4 model;
};

int main(void)
{
    Logger::Init();
    MemoryTracker::Init();

    // Load config
    state.config = FileSystem::ParseJSON("gamedata/game_settings.json");
    state.width = state.config["window"]["width"].template get<i32>();
    state.height = state.config["window"]["height"].template get<i32>();
    
    // Create window
    state.window = CreateRef<Window>(state.width, state.height);

    // Input
    Input::Init();

    // Create renderer
    RenderContext::Init();
    RenderContext::AttachWindow(state.window);
    RenderContext::InitImGui();

    // Create render graph
    state.graph = CreateRef<RenderGraph>();
    state.graph->PushNode(CreateRef<ForwardNode>());
    state.graph->PushNode(CreateRef<FXAANode>(state.graph->GetNode("Forward Pass")->GetFinalOutput()));
    state.graph->PushNode(CreateRef<CompositeNode>(state.graph->GetNode("FXAA Pass")->GetFinalOutput()));

    // TODO(ahi): Fix FXAA!!
    state.graph->GetNode("FXAA Pass")->Enable(false);

    // Initialize physics
    PhysicsSystem::Init();

    // Finalize initialisation
    LOG_INFO("Hello from ALLTH! Current game version: 0.0.1");

    // DT
    state.lastFrame = Timer::GetGlobalTime();

    // Debug scene
    Ref<Scene> scene = SceneSerializer::Deserialize(state.config["game"]["startupScene"]);

    // Game loop
    bool vsync = state.config["renderer"]["vsync"].template get<bool>();
    while (state.window->Open()) {
        f64 t = Timer::GetGlobalTime();
        f64 dt = t - state.lastFrame;
        state.lastFrame = t;

        state.window->PollSize(&state.width, &state.height);
        state.window->Update();

        // Process requests
        ReloadQueue::ProcessRequests();

        // Update loop
        scene->Update(dt);

        // Render Loop
        state.graph->Render(scene);

        // ImGui
        RenderContext::SetViewport(state.width, state.height);
        RenderContext::BindRenderTarget(RenderContext::GetBackBuffer());

        RenderContext::BeginUI();
        state.editorFocused = SceneEditor::Manipulate(scene);
        RenderContext::EndUI();

        // Present
        RenderContext::Present(vsync);

        // Clean
        Input::CompleteFrame();
    }

    // Write back config
    SceneSerializer::Serialize(scene, scene->GetPath());

    // Cleanup
    PhysicsSystem::Exit();
    RenderContext::ExitImGui();
    RenderContext::Exit();

    // Write back config
    state.config["window"]["width"] = state.width;
    state.config["window"]["height"] = state.height;
    FileSystem::WriteJSON("gamedata/game_settings.json", state.config);
    
    return 0;
}
