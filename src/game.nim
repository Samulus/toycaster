#
# game.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import window

const Title = "Game"

echo "Executing: " & Title & "\n"

var gameWindow: GameWindow;

if not createGameWindow(gameWindow):
  stderr.writeLine("Failure to create GameWindow", -1)

echo "Program Ended."
