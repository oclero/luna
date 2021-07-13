cmake_minimum_required(VERSION 3.19 FATAL_ERROR)

project(luna
	VERSION "1.0.0.0"
	LANGUAGES CXX
)

find_package(Qt5
	COMPONENTS
		Core
		Gui
		Widgets
		Quick
		QuickCompiler
		QuickControls2
		QuickTemplates2
		Qml
		Svg
	CONFIG REQUIRED
)

add_library(${PROJECT_NAME} STATIC)

target_compile_features(${PROJECT_NAME}
	PUBLIC
	cxx_std_17
)

target_compile_options(${PROJECT_NAME}
	PRIVATE
		$<$<CXX_COMPILER_ID:MSVC>:/MP>
)

set(SOURCES
	src/QmlEngineConfig.cpp
	src/ResourceInitialization.cpp
	src/controls/DoubleSpinBoxTemplate.cpp
	src/controls/IntegerSpinBoxTemplate.cpp
	src/controls/TreeViewAttached.cpp
	src/controls/TreeViewModelAdaptor.cpp
	src/controls/TreeViewModelAdaptor.hpp
	src/controls/TreeViewTemplate.cpp
	src/controls/TreeViewTemplatePrivate.cpp
	src/controls/TreeViewTemplatePrivate.hpp
	src/controls/Vector3dEditorTemplate.cpp
	src/utils/CursorHelper.cpp
	src/utils/DragHandler.cpp
	src/utils/IntegerSpinBoxHelper.cpp
)
set(HEADERS
	include/luna/QmlEngineConfig.hpp
	include/luna/ResourceInitialization.hpp
	include/luna/utils/CursorHelper.hpp
	include/luna/utils/DragHandler.hpp
	include/luna/utils/IntegerSpinBoxHelper.hpp
	include/luna/controls/DoubleSpinBoxTemplate.hpp
	include/luna/controls/IntegerSpinBoxTemplate.hpp
	include/luna/controls/TreeViewAttached.hpp
	include/luna/controls/TreeViewStyleHints.hpp
	include/luna/controls/TreeViewTemplate.hpp
	include/luna/controls/Vector3dEditorTemplate.hpp
)
set(RESOURCES
	qml/qml.qrc
	resources/resources.qrc
)

target_sources(${PROJECT_NAME} PRIVATE
	${SOURCES}
	${HEADERS}
	${RESOURCES}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
	SOVERSION ${PROJECT_VERSION_MAJOR}
	VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

set_target_properties(${PROJECT_NAME} PROPERTIES
	PUBLIC_HEADER "${HEADERS}"
)

target_include_directories(${PROJECT_NAME}
	PUBLIC
		"$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>"
		"$<INSTALL_INTERFACE:include>"
	PRIVATE
		"$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>"
)

set_target_properties(${PROJECT_NAME} PROPERTIES
	AUTOMOC ON
	AUTORCC ON
)

target_link_libraries(${PROJECT_NAME}
	PUBLIC
		Qt5::Quick
		Qt5::QuickPrivate
		Qt5::QuickTemplates2Private
		Qt5::Widgets
)

# QML Import dirs for Qt Creator.
list(APPEND QML_DIRS ${CMAKE_CURRENT_LIST_DIR}/qml)
set(QML_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra QML import paths" FORCE)
set(QML2_IMPORT_PATH "${QML_DIRS}" CACHE STRING "Qt Creator extra QML import paths (2)" FORCE)

add_subdirectory(example)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT example)
