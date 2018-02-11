#
# toycaster.nim
# Author: Samuel Vargas
#

import sdl2/sdl
import easygl
import opengl
import options

# Core Modules
import toycasterpkg/window
import toycasterpkg/event
import toycasterpkg/player
import toycasterpkg/input
import toycasterpkg/mouse
import toycasterpkg/tick
import toycasterpkg/units
import toycasterpkg/map
import toycasterpkg/minimap

# OpenGL Modules
import toycasterpkg/gl/minimapRender
import toycasterpkg/gl/playerIcon
import toycasterpkg/gl/wallRender
import toycasterpkg/gl/distanceTexture
import toycasterpkg/gl/colorTexture

# Create the main application window
var gameWindow: GameWindow;
if not createGameWindow(gameWindow):
  sdl.logCritical(LOG_CATEGORY_VIDEO, "Failure to create GameWindow", -1)
  quit(QuitFailure)

# Load map from disk into memory
let mapArr = fileToWorldMap("levels/001.txt")
if mapArr.isNone:
  sdl.logCritical(LOG_CATEGORY_APPLICATION, "Unable to open %s", "levels/001.txt")
  quit(QuitFailure)

# Init renderers
wallRender.init()

# Create player
let p = player.ctor(mapArr.get());

# Generate 1D uint8 texture with wall types
var wallColors = getColorTexture(gameWindow.width(), gameWindow.height())

# Generate 1D GLfloat (16) texture with wall heights
var distances = distanceTexture.regenerateImage(p, mapArr.get(), gameWindow.width(), gameWindow.height(), wallColors.bytes)
wallRender.use(gameWindow.width(), gameWindow.height(), distances, wallColors)

# Create game entities && start main loop
var running = true;

while running:
  # Tick gameloop every frame
  let dt = tick.update();

  # Handle Input
  let keyboard = getKeyboardState(nil)
  var
      direction: Direction
      rotation: Rotation

  if input.isQuitKey(keyboard):
    running = false
    break

  if input.isDirectionKey(keyboard, direction):
     p.move(direction)

  if input.isRotationKey(keyboard, rotation):
     p.rotate(rotation)

  #let mouseRotation = getMouseRotation(gameWindow.width(), gameWindow.height())
  #if mouseRotation < 0:
    #p.rotate(Rotation.Left)
  #elif mouseRotation > 0:
    #p.rotate(Rotation.Right)

  # Handle Events
  let event = getEvent()
  if event.isSome():
    case event.get().kind:

      # Application Quit Events
      of EventKind.QUIT:
        running = false;
        break;

      # Window Resize Event
      of EventKind.WINDOWEVENT:
        if event.get().window.event == WINDOWEVENT_RESIZED:
          let width = gameWindow.width()
          let height = gameWindow.height()
          distances = distanceTexture.regenerateImage(p, mapArr.get(), gameWindow.width(), gameWindow.height(), wallColors.bytes)
          window.resize(width, height)

      else:
        discard

  # Update Game
  while tick.hasLag():
    p.update(dt, mapArr.get())

  # Render Game
  distances = distanceTexture.regenerateImage(p, mapArr.get(), gameWindow.width(), gameWindow.height(), wallColors.bytes)
  window.clear()
  wallRender.use(gameWindow.width().uint, gameWindow.height().uint, distances, wallColors)
  wallRender.render()
  window.swap(gameWindow)
