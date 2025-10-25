cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Binary and App ID come from the top-level CMakeLists.txt.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply common Flutter compiler settings.
apply_standard_settings(${BINARY_NAME})

# Preprocessor definition for app ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# ---- Link dependencies ----
# Flutter runtime
target_link_libraries(${BINARY_NAME} PRIVATE flutter)

# GTK (UI framework)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

# MediaKit backend (Linux MPV-based playback)
find_package(PkgConfig REQUIRED)
pkg_check_modules(MPV QUIET mpv)
if(MPV_FOUND)
  target_link_libraries(${BINARY_NAME} PRIVATE ${MPV_LIBRARIES})
  target_include_directories(${BINARY_NAME} PRIVATE ${MPV_INCLUDE_DIRS})
endif()

# Include root headers
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Set RPATH so Flutter can find libs at runtime
set_target_properties(${BINARY_NAME}
  PROPERTIES
  INSTALL_RPATH "$ORIGIN/lib"
)
