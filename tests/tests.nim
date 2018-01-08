#
# tests/tests.nim
# Author: Samuel Vargas
#

import glm
import math
import unittest
import sequtils
import ../src/gamepkg/gl/distanceTexture
import ../src/gamepkg/player
import ../src/gamepkg/map

suite "Player Spawning / Movement / Rotation":
    setup:
        let
            mapData = @["102\n000\n101",
                        "101\n020\n101",
                        "101\n000\n121"]
            spawns = @[vec2f(2.5, 0.5),
                       vec2f(1.5, 1.5),
                       vec2f(1.5, 2.5)]
        var
            index = 0

    test "Player Spawns in Middle of Cells":
        require (len(mapData) == len(spawns))
        while index < len(mapData):
            let
                map = mapData[index].stringToWorldMap()
                playerObj = player.ctor(map)
            check(playerObj.position == spawns[index])
            index = index + 1

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