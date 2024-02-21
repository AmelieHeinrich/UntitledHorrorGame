-- 
-- @Author: Amélie Heinrich
-- @Create Time: 2024-02-18 01:31:39
-- 

add_rules("mode.debug", "mode.release")

includes("vendor")

target("Game")
    set_languages("c++17")
    set_rundir(".")
    add_deps("JSON", "spdlog", "GLFW", "stb", "imgui")
    add_files("src/*.cpp", "src/core/*.cpp", "src/renderer/*.cpp", "src/asset/*.cpp", "src/game/*.cpp", "src/util/*.cpp")
    add_includedirs("vendor", "src")
    add_syslinks("d3d11", "dxgi", "d3dcompiler", "comdlg32")
    add_linkdirs("vendor/assimp/bin")

    if is_mode("debug") then
        set_symbols("debug")
        set_optimize("none")
        add_links("assimp-vc143-mtd.lib")
    end

    if is_mode("release") then
        set_symbols("hidden")
        set_optimize("fastest")
        set_strip("all")
        add_links("assimp-vc143-mt.lib")
    end
