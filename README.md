# VoidCPP: A PowerShell script to automate the process of setting up a C++ project

## Introduction

This PowerShell script is designed to automate the process of setting up a C++ project. It provides a simple interface for creating a new project, building it, and running it. The script can also be used to compile a single source file.

## Setup

To use the script, you need to have the following installed:

- PowerShell
- CMake version 3.30.4 or later

### Installation

1. Clone the repository to your local machine.
2. Open PowerShell and navigate to the directory where you cloned the repository.
3. Run the following command:

```powershell
.\voidcpp.ps1
```

This will make the script available in your PowerShell profile.

> Note: for permanent usage, you can add the script to your $PROFILE file.

## Usage

To use the script, follow these steps:

1. Open PowerShell and navigate to the directory where you want to create the project.
2. Run the following command:

```powershell
vcpp init <project_name>
```

Replace `<project_name>` with the desired name for your project. This will create a new directory with the specified name and set up the basic structure for your project.

> Note: if you don't specify a project name, the script will initialize in the current directory and use its name as the project name.


3. Open the project in Visual Studio Code or your preferred editor.
4. Run the following command:

```powershell
vcpp build <configuration>
```

Replace `<configuration>` with either `Debug` or `Release`. This will build the project using the specified configuration.

5. Run the following command:

```powershell
vcpp run <filename>
```

Replace `<filename>` with the name of the executable file you want to run. If you don't specify a filename, the script will run the executable with the most recently modified file in the `Binaries` directory (i.e. the current project).

6. Run the following command:

```powershell
vcpp make <filename>
```

Replace `<filename>` with the name of the source file you want to compile. (this has nothing to do with projects, it only compiles a single source file)

## Features

The script provides the following features:

- Create a new project with a basic structure.
- Build the project using CMake.
- Run the project.
- Compile a source file.

## Limitations

The script has the following limitations:

- It only supports C++23 and later.
- It only supports Windows.

## Contributing

Contributions are welcome! If you have any suggestions or improvements, please open an issue or submit a pull request.
