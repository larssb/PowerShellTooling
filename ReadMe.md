# Synopsis.

PowerShellTooling is a self-developed proprietary module. It contains many small helper functions. Instead of having theese functions scattered around or copied into whatever new module I was developing, I made this PowerShell module, to be able to adhere to the DRY principle and to ease the workload of developing new PowerShell modules.

N.B. This module is a strong dependency of the HealOps module. Find HealOps here [HealOps-module][HealOps_OnGitHub]

# Deploying/Installing PowerShellTooling

1. Git clone it
2. Open VS Code (the repo is sooo ready for you using VS Code)
3. Execute the default build task by hitting `Ctrl-b` on Windows or `Shift-Cmd-b` on MacOS
    1. Requires that the Invoke-Build PowerShell module is installed. Get it here [Invoke-Build][Invoke-Build_Module]

# What's included?

The below will give an overview of what is included and at the same time

## DataManipulation

Tools for transforming data to other types of data. Working with files and so forth.

## Debugging

Functions helps you debug PowerShell code as well as log exceptions and the like.

## JobScheduling

Functions that helps you interact with `Scheduled Tasks` on Windows or `cron` on MacOS and Linux.

## PowerShellInfo

A collection of functions that helps you get info on PowerShell. System-wide, module specific and the PowerShell session/instance state.

## SystemInfo

These functions gives you system info such as what type of OS it is. The hostname of the system and so forth.

## Various

Different functions that haven't found a better home.

[//]: # "Links"
[Invoke-Build_Module]: https://github.com/nightroman/Invoke-Build
[HealOps_OnGitHub]: https://github.com/larssb/HealOps