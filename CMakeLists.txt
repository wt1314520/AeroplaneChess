cmake_minimum_required(VERSION 4.1.1)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
# cmake_minimum_required(VERSION 4.3.2)
# set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
set(CMAKE_CXX_MODULE_STD ON)

project(AeroplaneChess VERSION 0.1 LANGUAGES CXX)
set(QT_QML_GENERATE_QMLLS_INI ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appAeroplaneChess  WIN32)
qt_add_qml_module(appAeroplaneChess
    URI AeroplaneChess
    VERSION 1.0
    SOURCES     main.cpp
    QML_FILES   main.qml
    SOURCES GameEngine.h
    SOURCES GameEngine.cpp
    RESOURCES ../images/plane_green.png
    RESOURCES ../images/board.png ../images/plane_red.png ../images/plane_yellow.png ../images/plane_blue.png
)
target_compile_features(appAeroplaneChess PRIVATE cxx_std_23)
target_link_libraries(appAeroplaneChess
    PRIVATE Qt6::Quick
)

set(CMAKE_INSTALL_PREFIX "/opt/${PROJECT_NAME}" CACHE PATH "Install path prefix" FORCE)
install(TARGETS appAeroplaneChess
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# C++ Modules support
set(AEROPLANECHESS_MODULE_FILES
    # math.cppm                             # 模块文件
)
source_group("AeroplaneChess" FILES ${AEROPLANECHESS_MODULE_FILES})
target_sources(appAeroplaneChess
    PRIVATE FILE_SET cxx_modules TYPE CXX_MODULES
        BASE_DIRS   ${CMAKE_CURRENT_SOURCE_DIR}
        FILES  ${AEROPLANECHESS_MODULE_FILES}
)
