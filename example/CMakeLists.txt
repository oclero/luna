# Create an imported target.
function(find_deploy_qt)
	get_target_property(QMAKE_LOCATION Qt5::qmake IMPORTED_LOCATION)
	get_filename_component(QT_BINARY_DIR ${QMAKE_LOCATION} DIRECTORY)

	if(WIN32)
		find_program(DEPLOYQT_EXE "windeployqt" HINTS "${QT_BINARY_DIR}" REQUIRED)
		set(${DEPLOYQT_EXE} ${DEPLOYQT_EXE} PARENT_SCOPE)
	elseif(APPLE)
		find_program(DEPLOYQT_EXE "macdeployqt" HINTS "${QT_BINARY_DIR}" REQUIRED)
		set(${DEPLOYQT_EXE} ${DEPLOYQT_EXE} PARENT_SCOPE)
	endif()
endfunction()

# Copies Qt libs after building the target.
function(target_deploy_qt TARGET_NAME)
	cmake_parse_arguments(LOCAL "" "QML_DIRECTORY" "" ${ARGN})

	find_deploy_qt()
	if(${DEPLOYQT_EXE})
		if(WIN32)
			set(TEMPORARY_DIR "$<TARGET_FILE_DIR:${TARGET_NAME}>/_deployqt")
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
				COMMAND ${DEPLOYQT_EXE} --verbose 0 "$<$<BOOL:${LOCAL_QML_DIRECTORY}>:--qmldir \"${LOCAL_QML_DIRECTORY}\">" --no-patchqt --no-compiler-runtime --no-webkit2 --no-system-d3d-compiler --no-translations --no-angle --no-opengl-sw --dir "${TEMPORARY_DIR}" "$<TARGET_FILE:${TARGET_NAME}>"
				COMMAND ${CMAKE_COMMAND} -E copy_directory "${TEMPORARY_DIR}" "$<TARGET_FILE_DIR:${TARGET_NAME}>"
				COMMENT "Deploying Qt..."
			)
		elseif(APPLE)
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
				COMMAND ${DEPLOYQT_EXE} "$<TARGET_BUNDLE_DIR:${TARGET_NAME}>" -verbose=0 -always-overwrite -qmldir="${LOCAL_QML_DIRECTORY}" -qmlimport="${CUSTOM_QML_IMPORT_DIR}"
				COMMENT "Deploying Qt to ${TARGET_NAME} bundle..."
			)
		endif()
	endif()
endfunction()

add_executable(example WIN32 MACOSX_BUNDLE
	main.cpp
	example.qrc
)

target_link_libraries(example
	PUBLIC
		luna
)

set_target_properties(example PROPERTIES
	AUTOMOC ON
	AUTORCC ON
)

# Deploy when post-build.
target_deploy_qt(example
	QML_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../qml)
