#
# tests/tests.nim
# Author: Samuel Vargas
#

import glm
import math
import unittest
import sequtils
import options
import ../src/gamepkg/gl/distanceTexture
import ../src/gamepkg/player
import ../src/gamepkg/map
import ../src/gamepkg/units

const
    MaximumDifference = 0.0001

suite "Player Spawning / Movement / Rotation":
    setup:
        let
            mapData = "101\n020\n101"
            playerObj = player.ctor(mapData.stringToWorldMap())

    test "Spawn in center of map cell":
        check(playerObj.position == vec2f(1.5, 1.5))

    test "Face North by default (theta = 90 degrees)":
        require(abs(playerObj.theta - (math.Pi / 2)) < MaximumDifference)
        require(abs(playerObj.velocity.x - 0f) < MaximumDifference)
        require(abs(playerObj.velocity.y - 1.0f) < MaximumDifference)

    test "Theta increases / velocity changes, when player looks to the left":
        let
            deltaTime = 1.0  # One full second has elapsed
            prevTheta = playerObj.theta # Record original angle of player
            expectedTheta = 180.0f.degToRad() # aka Π
        playerObj.move(Direction.Left, true)
        playerObj.update(deltaTime, rotateSpeed = 90.0f.degToRad()) # Face completely west

        require(playerObj.theta > prevTheta) # Theta should increase
        require(abs(playerObj.theta - expectedTheta) < MaximumDifference) # Theta should be Π

        # When facing completely West:
        require(playerObj.velocity.x < 0) # X velocity should be negative 1
        require(abs(playerObj.velocity.x + 1) < MaximumDifference) # (-1 + 1) < MaximumDifference if X velocity is -1
        require(abs(playerObj.velocity.y) < MaximumDifference) # Y velocity should be 0

    test "Theta decreases / velocity changes, when player looks to the right":
        let
            deltaTime = 1.0  # One full second has elapsed
            prevTheta = playerObj.theta # Record original angle of player
            expectedTheta = 0
        playerObj.move(Direction.Right, true)
        playerObj.update(deltaTime, rotateSpeed = 90.0f.degToRad()) # Face completely East

        require(playerObj.theta < prevTheta) # Theta should decrease
        require(abs(playerObj.theta) < MaximumDifference) # Theta should be 0

        # When facing completely East:
        require(playerObj.velocity.x > 0) # X velocity should be positive 1
        require(abs(playerObj.velocity.x - 1) < MaximumDifference) # (+1 - 1) < MaximumDifference if X velocity is +1
        require(abs(playerObj.velocity.y) < MaximumDifference) # Y Velocity should be 0

    test "Player enters cell(0.5, 1.5f) after rotating +90 deg and moving 1 meter":
        let
            deltaTime = 1.0 # Seconds
            prevTheta = playerObj.theta
            rotateSpeed = 90.0f.degToRad()
            walkSpeed = 1.0f # Meters / second
            expectedX = 0.5f # Expected x position after movement
            expectedY = 1.5f # Expected y position after movement

        # Rotate completely to the left and walk into the next cell
        playerObj.move(Direction.Left, true)
        playerObj.update(deltaTime, rotateSpeed = rotateSpeed)
        playerObj.move(Direction.Forward, true)
        playerObj.update(deltaTime, walkSpeed = walkSpeed)
        require(playerObj.position.x - expectedX < MaximumDifference)
        require(playerObj.position.y - expectedY < MaximumDifference)

suite "Raycasting Algorithm":
    setup:
        let mapData =  "101\n020\n101".stringToWorldMap()
        let playerObj = player.ctor(mapData)

    test "getNormalizedCartesianLocation() returns correct values":
        let a = getNormalizedCartesianLocation(vec2f(1.5, 0.5)) # Expected (0, 0)
        require(abs(a.x) < MaximumDifference)
        require(abs(a.y) < MaximumDifference)
        let b = getNormalizedCartesianLocation(vec2f(0.0, 0.0)) # Expected: (-1, 1)
        require(b.x < 0)
        require(b.y > 0)
        require(abs(b.x) - 1.0f < MaximumDifference)
        require(abs(b.y) - 1.0f < MaximumDifference)
        let c = getNormalizedCartesianLocation(vec2f(128.9, 666.9)) # Expected: (0.9, -0.9)
        require(c.x > 0)
        require(c.y < 0)
        require(abs(c.x) - 0.9f < MaximumDifference)
        require(abs(c.y) - 0.9f < MaximumDifference)


    test "Horizontal Intersection Test [Facing: Up]":
        playerObj.theta = 120.0f.degToRad()
        let quadrant = playerObj.theta.getQuadrant()
        require(quadrant == Quadrant.II)