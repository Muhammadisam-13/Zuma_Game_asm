
# Zuma Game

A console-based version of the game 'Zuma', made in x86 MASM Assembly and the Irvine Library.


## Features

- Ball shooting mechanism
- Ball chaining mechanism
- Three exciting levels
- Increasing difficulty, new paths and colors each level
- Instructions menu and pause functionality
- Press 'O' to skip levels


## Contributions

This was a solo project so I am the sole contributor of it.
## Configuration for MASM Visual Studios project and Irvine32
- Extract the zip file named 'Irvine.zip' contained in the 'zuma_game_asm' folder, to your C drive
- Create C++ empty project.
- Right-click project file name - Build dependencies - build customization- Check masm
- Right-click project file name- properties
- Linker-General : Additional directory libraries - c:\Irvine
- Linker-Input: Additional dependencies: Irvine32.lib;
- Linker-System: Subsystem - Console\
- Add item, C++ file, name it as main.asm.
- Include Path c:\Irvine for ASM file: properties- Microsoft Macro Assembler-General: Include Paths - c:\Irvine\

## Credits
Assembly Language for x86 Processors, Sixth Edition.

