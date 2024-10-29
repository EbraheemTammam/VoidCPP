function vcpp
{
    param (
        [string]$command,
        [string]$2 = "."
    )

    switch ($command)
    {
        "init"
        {
            $project_name = $2

            if (-Not ($project_name -eq "."))
            {
                Write-Output "Creating root directory..."
                New-Item -ItemType Directory -Path $project_name
                Set-Location $project_name
            }
            else
            {
                $project_name = Get-Item -Path "." -Force | Select-Object -ExpandProperty Name
            }

            Set-Content -Path ".\CMakeLists.txt" -Value @"
cmake_minimum_required(VERSION 3.30.4)

project($project_name)

# Set the architecture to x64
set(CMAKE_CXX_ARCHITECTURE_ID x64)

# Set configurations
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

# Set the start project
set_property(DIRECTORY `$`{CMAKE_CURRENT_SOURCE_DIR`} PROPERTY VS_STARTUP_PROJECT "$project_name.Application")

# Output directory
set(OutputDir "`$`{CMAKE_SYSTEM_NAME`}-`$`{CMAKE_SYSTEM_PROCESSOR`}/`$<CONFIG>")

# Group Core
add_subdirectory("$project_name.Core")

# Group App
add_subdirectory("$project_name.Application")
"@

            New-Item -ItemType Directory -Path "$project_name.Core"
            New-Item -ItemType Directory -Path "$project_name.Core\Source"

            Set-Content -Path "$project_name.Core\Source\PCH.h" -Value @"
#pragma once

#include <iostream>
#include <fstream>
#include <mutex>
#include <thread>
#include <memory>
#include <string>
#include <string_view>
#include <chrono>
#include <ctime>
#include <format>
"@

            Set-Content -Path "$project_name.Core\Source\Logger.h" -Value @"
#pragma once

#include "PCH.h"

namespace $project_name::Core { class Logger; }

class $project_name::Core::Logger
{
    public: enum struct LogLevel { Info, Warning, Error };
    public: enum struct Output { Console,File };
    public: static Logger& getInstance();
    public: void setLogLevel(LogLevel level);
    public: void setOutput(Output output);
    public: void log(LogLevel level, std::string_view message);
    public: void info(std::string_view message);
    public: void warning(std::string_view message);
    public: void error(std::string_view message);

    private: Logger(const Logger&) = delete;
    private: Logger& operator=(const Logger&) = delete;
    private: Logger() : logLevel_(LogLevel::Info), output_(Output::Console) {}
    private: std::string getCurrentTime() const;
    private: const char* to_string(LogLevel level) const;
    private: LogLevel logLevel_;
    private: Output output_;
    private: mutable std::mutex mutex_;
};
"@

            Set-Content -Path "$project_name.Core\Source\Logger.cpp" -Value @"
#include "Logger.h"

$project_name::Core::Logger& $project_name::Core::Logger::getInstance()
{
    static Logger instance;
    return instance;
}

void $project_name::Core::Logger::setLogLevel(LogLevel level)
{
    std::lock_guard<std::mutex> lock(mutex_);
    logLevel_ = level;
}

void $project_name::Core::Logger::setOutput(Output output)
{
    std::lock_guard<std::mutex> lock(mutex_);
    output_ = output;
}

void $project_name::Core::Logger::log($project_name::Core::Logger::LogLevel level, std::string_view message)
{
    if (level < logLevel_) return;

    std::lock_guard<std::mutex> lock(mutex_);
    std::string logEntry = std::format("{} [{}] {}\n", getCurrentTime(), to_string(level), message);

    if (output_ == Output::Console) {
        std::cout << logEntry;
    } else {
        std::ofstream logFile("log.txt", std::ios_base::app);
        logFile << logEntry;
    }
}

void $project_name::Core::Logger::info(std::string_view message)
{
    log(LogLevel::Info, message);
}

void $project_name::Core::Logger::warning(std::string_view message)
{
    log(LogLevel::Warning, message);
}

void $project_name::Core::Logger::error(std::string_view message)
{
    log(LogLevel::Error, message);
}

std::string $project_name::Core::Logger::getCurrentTime() const
{
    using std::chrono::_V2::system_clock;
    using std::chrono::duration_cast;
    using std::chrono::milliseconds;
    using millisec = std::chrono::duration<int64_t, std::milli>;

    auto now = system_clock::now();
    time_t in_time_t = system_clock::to_time_t(now);
    millisec milliseconds_ = duration_cast<milliseconds>(now.time_since_epoch()) % 1000;

    std::ostringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %H:%M:%S");
    ss << '.' << std::setfill('0') << std::setw(3) << milliseconds_.count();

    return ss.str();
}

const char* $project_name::Core::Logger::to_string(LogLevel level) const
{
    switch (level) {
        case LogLevel::Info: return "INFO";
        case LogLevel::Warning: return "WARNING";
        case LogLevel::Error: return "ERROR";
        default: return "UNKNOWN";
    }
}
"@

            Set-Content -Path "$project_name.Core\CMakeLists.txt" -Value @"
cmake_minimum_required(VERSION 3.30.4)

project($project_name.Core LANGUAGES CXX)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core)
set(CMAKE_PDB_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/Intermediates/`$<CONFIG>/$project_name.Core)

# Define the target
add_library($project_name.Core STATIC)

# Get all source files while ignoring the build directory
file(GLOB_RECURSE SOURCES "Source/*.cpp" "Source/*.h")

# Source files and include directories
target_sources($project_name.Core PRIVATE `$`{SOURCES`})
target_include_directories($project_name.Core PRIVATE Source)

# Add precompiled header
target_precompile_headers($project_name.Core PRIVATE Source/PCH.h)

# Windows-specific settings
if (WIN32)
    target_compile_definitions($project_name.Core PRIVATE SYSTEM_VERSION_LATEST)
endif()

# Configurations
set_target_properties($project_name.Core PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core
    ARCHIVE_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core
    LIBRARY_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Core
)

# Configuration specific settings
target_compile_definitions($project_name.Core PRIVATE
    `$<`$<CONFIG:Debug>:DEBUG>
    `$<`$<CONFIG:Release>:RELEASE>
)
target_compile_options($project_name.Core PRIVATE
    `$<`$<CONFIG:Debug>:/MDd>
    `$<`$<CONFIG:Release>:/MD>
)
target_compile_options($project_name.Core PRIVATE
    `$<`$<CONFIG:Debug>:/Zi>
    `$<`$<CONFIG:Release>:/O2 /Zi>
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options($project_name.Core PRIVATE -g)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options($project_name.Core PRIVATE -O3)
endif()
"@

            New-Item -ItemType Directory -Path "$project_name.Application"
            Set-Content -Path "$project_name.Application\CMakeLists.txt" -Value @"
cmake_minimum_required(VERSION 3.30.4)

project($project_name.Application LANGUAGES CXX)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application)
set(CMAKE_PDB_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/Intermediates/`$<CONFIG>/$project_name.Application)


# Get all source files while ignoring the build directory
file(GLOB_RECURSE SOURCES "Source/*.cpp" "Source/*.h")

# Source files and include directories
target_sources($project_name.Core PRIVATE `$`{SOURCES`})

# Define the target
add_executable($project_name.Application `$`{SOURCES`})

target_include_directories($project_name.Application PRIVATE Source ../$project_name.Core/Source)

# Link against the $project_name.Core library
target_link_libraries($project_name.Application PRIVATE $project_name.Core)

# Windows-specific settings
if (WIN32)
    target_compile_definitions($project_name.Application PRIVATE WINDOWS)
endif()

# Configurations
set_target_properties($project_name.Application PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application
    ARCHIVE_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application
    LIBRARY_OUTPUT_DIRECTORY `$`{CMAKE_BINARY_DIR`}/../Binaries/`$<CONFIG>/$project_name.Application
)

# Configuration specific settings
target_compile_definitions($project_name.Application PRIVATE
    `$<`$<CONFIG:Debug>:DEBUG>
    `$<`$<CONFIG:Release>:RELEASE>
)
target_compile_options($project_name.Application PRIVATE
    `$<`$<CONFIG:Debug>:/MDd>
    `$<`$<CONFIG:Release>:/MD>
)
target_compile_options($project_name.Application PRIVATE
    `$<`$<CONFIG:Debug>:/Zi>
    `$<`$<CONFIG:Release>:/O2 /Zi>
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options($project_name.Application PRIVATE -g)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    target_compile_options($project_name.Application PRIVATE -O3)
endif()
"@
            New-Item -ItemType Directory -Path "$project_name.Application\Source"

            Set-Content -Path "$project_name.Application\Source\main.cpp" -Value @"
#include <PCH.h>
#include <Logger.h>

using $project_name::Core::Logger;

int main()
{
    Logger& logger = Logger::getInstance();
    logger.setLogLevel(Logger::LogLevel::Info);
    logger.setOutput(Logger::Output::Console);
    logger.info("Hello World!");

    return 0;
}
"@
	    }

        "build"
        {
            $config = $2

            if ($config -eq ".")
            {
                $config = "Debug"
            }

            Write-Output "Building the project with CMake..."

            if($config -eq "Debug")
            {
                cmake -S . -B Build
                cmake --build Build --config Debug
            }
            elseif($config -eq "Release")
            {
                cmake -S . -B Build
                cmake --build Build --config Release
            }
            else
            {
                Write-Output "Invalid configuration. Use 'Debug' or 'Release'."
                return
            }
            cmake --build Build
        }

        "run"
        {
            $filename = $2
            if(-Not ($filename -eq "."))
            {
                & $filename
                return
            }

            $exeFiles = Get-ChildItem .\Binaries\*.Application\*.exe | Sort-Object LastWriteTime -Descending

            if ($exeFiles.Count -gt 0)
            {
                & $exeFiles[0].FullName
            }
            else
            {
                Write-Output "No executables found in the bin directory."
            }
        }

        "make"
        {
            $filename = $2

            if ($filename)
            {
                $output = [System.IO.Path]::GetFileNameWithoutExtension($filename)
                Write-Output "Compiling $filename..."
                $cmd = "g++ -std=c++23 $filename -o $output.exe --time"
                Invoke-Expression $cmd
            }
            else
            {
                Write-Output "Please provide a filename for the 'make' command."
            }
        }

        Default
        {
            Write-Output "Invalid command. Use 'init', 'build', 'run', or 'make'."
        }
    }
}
