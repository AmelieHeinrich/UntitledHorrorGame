# Untitled Horror Game

This is an attempt at creating a 3D psychological horror game from scratch using no engine and raw C++.

## Building

To build this project, you need to have the xmake build system installed.

```bash
xmake
xmake run
# That's it lol! You can also use xmake f --mode=release or xmake f --mode=debug to change configurations
```

## Current features of the homemade engine

- Asset loading through stb_image and Assimp
- Core engine utilities like logging, timing, windowing, an input and a file system
- Platform utilities like file dialogs
- D3D11 rendering backend and tidy wrapper for interacting with the GPU
- JSON config parsing for game settings
- JSON de/serialization of game scenes (check gamedata/scenes/plaza_scene.json for an example)
- Live reloading of assets if needed
- Scene system with game objects
- Scene editor through ImGui, ImGuizmo
- Free Camera to navigate through the world
- Very basic render graph implementation with the following construction:
    - Forward pass
    - FXAA pass
    - Composition pass

## Bugs

- Renderer:
    - FXAA does not work
    - Texture memory tracking seems to be inaccurate

## Roadmap (Unordered)

- Physics:
    - Simple AABB body creation
    - Collision checks
    - Gravity
    - Raycast checks
- Audio:
    - Simple audio file streaming through miniaudio
    - Audio spatialization
    - Audio materials for step sounds
    - Sound graphs for filters and effects
- Rendering:
    - Add simple lighting
    - Point lights, area lights, cone lights
    - Forward+ or deferred
    - Skybox from a .hdr file
    - Eye adaptation
    - Instancing
    - Fog (toggable for open/closed maps)
    - Screen space ambient occlusion
    - Bloom
    - Sharpening
    - LUT
    - Video cutscenes through ffmpeg
- Game:
    - Door system
    - Inventory system
    - Menu system
    - Map design
    - Simple behaviour scripting with Lua for certain objects
- Optimisation:
    - Thread pool for asset loading, game update/render, physics
    - Frustum culling
    - Occlusion culling
    - Asset compression
- Polishing:
    - Intertionalization
    - Asset packaging
    - Play testing, bug fixing
