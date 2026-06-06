cmake_minimum_required(VERSION 3.21)
project(SNAnimGS_UI VERSION 1.0.0 LANGUAGES CXX)

# Optional auto-copy of the built DLL to the mod. Set SKYRIM_MODS_FOLDER to your mod
# manager's mods folder (the parent of SkyrimNet_AnimationsGS).
if(DEFINED ENV{SKYRIM_MODS_FOLDER} AND IS_DIRECTORY "$ENV{SKYRIM_MODS_FOLDER}")
    set(OUTPUT_FOLDER "$ENV{SKYRIM_MODS_FOLDER}/SkyrimNet_AnimationsGS")
endif()

find_package(CommonLibSSE CONFIG REQUIRED)

add_commonlibsse_plugin(${PROJECT_NAME}
    SOURCES
        src/Plugin.cpp
        src/PapyrusFunctions.cpp
        src/PrismaUIBridge.cpp
)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_precompile_headers(${PROJECT_NAME} PRIVATE src/PCH.h)

# Dynamic CRT (/MD) + static libs — matches the x64-windows-static-md vcpkg triplet
# (see CMakePresets.json). Required so std::string/std::function cross the PrismaUI
# DLL boundary safely without depending on a shared spdlog/fmt DLL.
set_property(TARGET ${PROJECT_NAME} PROPERTY
    MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

target_include_directories(${PROJECT_NAME} PRIVATE include src)

if(DEFINED OUTPUT_FOLDER)
    set(DLL_FOLDER "${OUTPUT_FOLDER}/SKSE/Plugins")
    message(STATUS "SKSE plugin output folder: ${DLL_FOLDER}")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${DLL_FOLDER}"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:${PROJECT_NAME}>"
            "${DLL_FOLDER}/$<TARGET_FILE_NAME:${PROJECT_NAME}>"
        VERBATIM)
else()
    message(WARNING "SKYRIM_MODS_FOLDER not set — the built DLL will NOT be auto-copied. "
                    "Copy the built SNAnimGS_UI.dll to <SkyrimNet_AnimationsGS mod>/SKSE/Plugins/ manually.")
endif()
