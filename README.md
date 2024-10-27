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

> Note: for permanent usage, you can add the script to your `$PROFILE` file.

## Usage

### Initializing new project

1. Open PowerShell and navigate to the directory where you want to create the project.
2. Run the following command:

```powershell
vcpp init <project_name>
```

Replace `<project_name>` with the desired name for your project. This will create a new directory with the specified name and set up the basic structure for your project.

> Note: if you don't specify a project name, the script will initialize in the current directory and use its name as the project name.

***

### Building the project

Run the following command in the project directory:

```powershell
vcpp build <configuration>
```

Replace `<configuration>` with either `Debug` or `Release`. This will build the project using the specified configuration.

***

### Running the project

Run the following command:

```powershell
vcpp run
```

The script will run the executable with the most recently modified file in the `Binaries` directory.

***

### Compiling a source file

```powershell
vcpp make <filename>
```

Replace `<filename>` with the name of the source file you want to compile.

## Contributing

Contributions are welcome! If you have any suggestions or improvements, please open an issue or submit a pull request.
