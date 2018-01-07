#
# tests/tests.nim
# Author: Samuel Vargas
#

import glm
import math
import unittest
import ../src/gamepkg/gl/distanceTexture
import ../src/gamepkg/player
import ../src/gamepkg/map

suite "Raycasting Algorithm":
    setup:
        let mapData =  "101\n020\n101".stringToWorldMap()
        let playerObj = player.ctor(mapData)
        playerObj.cell = vec2f(2, 1)
        playerObj.position = vec2f(1.5, 2.5)

    test "Horizontal Intersection Test [Facing: Up]":
        playerObj.theta = 120.0f.degToRad()
        let quadrant = playerObj.theta.getQuadrant()
        require(quadrant == Quadrant.II)