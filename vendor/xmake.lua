-- 
-- @Author: Amélie Heinrich
-- @Create Time: 2024-02-18 11:40:15
-- 

target("JSON")
    set_kind("static")
    add_files("nlohmann/*.cpp")
    add_includedirs(".")

target("spdlog")
    set_kind("static")
    add_files("spdlog/*.cpp")
    add_includedirs(".")
    add_cxxflags("-DSPDLOG_COMPILED_LIB")

target("GLFW")
    set_kind("static")
    add_files("GLFW/*.c")
    add_includedirs(".", "GLFW")

    if is_plat("windows") then
        add_syslinks("gdi32", "kernel32", "user32", "shell32")
    end

target("stb")
    set_kind("static")
    add_files("stb/stb.c")

target("imgui")
    set_kind("static")
    add_files("imgui/*.cpp")
    add_deps("GLFW")
    add_syslinks("d3d11", "dxgi")
    add_includedirs(".")