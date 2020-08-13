# Sonar Game in PowerShell

Sonar Treasure Hint Game is a text based game based on the one found in Al Sweigart's book [Invent Your Own Computer Games with Python][Booklink]. (Great book!)

## Description

This is a port of the original Python game into PowerShell. 
One of the interesting challenges during porting was translating Python's *in* and *not in* operators to PowerShell *piping* to search for the existance of an object in an array of objects. It also uses .Net Framework classes for useful methods and data types like a square root method and an *array list* instead of the default array type in PowerShell.

## How to play

The game is played exactly as the original Python version.
Guess coordinates of treasure chests until all are found or until all sonar devices are used.

## Installation

Clone this repo or download.

## Usage

The simplest way to run this game is to dot source it in a PowerShell prompt. It's been tested with PowerShell 5.1 at this time.

```
. .\sonar_game.ps1
```

Another way to run it is to open it in VisualStudio Code with the PowerShell extension or the PowerShell ISE and run it from there.

## Testing

A small suite of tests in Pester is available if you want to make changes to certain parts of the game, like the number of treasure chests, and verify that it still works.

To test run *Invoke-Pester* from within the game folder.

## License

This version is made freely available under a Creative Commons BY-NC-SA license like the work it is based on.

[Booklink]: https://inventwithpython.com/#invent