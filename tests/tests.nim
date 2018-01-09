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
import ../src/gamepkg/raycast
import ../src/gamepkg/player
import ../src/gamepkg/map
import ../src/gamepkg/units

const
    MaximumDifference = 0.0001
    AlmostZero = MaximumDifference
    OneSecondDeltaTime = 1.0f
    # If theta is at an extreme angle and a collision is
    # never going to be made the getIntersection functions
    # will return a value smaller or larger than these
    # arbitrarily chosen values respectively
    SmallKnownValue = -10_000.0f
    LargeKnownValue = -1 * SmallKnownValue

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
            prevTheta = playerObj.theta # Record original angle of player
            expectedTheta = 180.0f.degToRad() # aka Π
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad()) # Face completely west

        require(playerObj.theta > prevTheta) # Theta should increase
        require(abs(playerObj.theta - expectedTheta) < MaximumDifference) # Theta should be Π

        # When facing completely West:
        require(playerObj.velocity.x < 0) # X velocity should be negative 1
        require(abs(playerObj.velocity.x + 1) < MaximumDifference) # (-1 + 1) < MaximumDifference if X velocity is -1
        require(abs(playerObj.velocity.y) < MaximumDifference) # Y velocity should be 0

    test "Theta decreases / velocity changes, when player looks to the right":
        let
            prevTheta = playerObj.theta # Record original angle of player
            expectedTheta = 0
        playerObj.move(Direction.Right, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad()) # Face completely East

        require(playerObj.theta < prevTheta) # Theta should decrease
        require(abs(playerObj.theta) < MaximumDifference) # Theta should be 0

        # When facing completely East:
        require(playerObj.velocity.x > 0) # X velocity should be positive 1
        require(abs(playerObj.velocity.x - 1) < MaximumDifference) # (+1 - 1) < MaximumDifference if X velocity is +1
        require(abs(playerObj.velocity.y) < MaximumDifference) # Y Velocity should be 0

    test "Player enters cell(0.5, 1.5f) after rotating +90 deg and moving 1 meter":
        let
            prevTheta = playerObj.theta
            rotateSpeed = 90.0f.degToRad()
            walkSpeed = 1.0f # Meters / second
            expectedX = 0.5f # Expected x position after movement
            expectedY = 1.5f # Expected y position after movement

        # Rotate completely to the left and walk into the next cell
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = rotateSpeed)
        playerObj.move(Direction.Forward, true)
        playerObj.update(OneSecondDeltaTime, walkSpeed = walkSpeed)
        require(playerObj.position.x - expectedX < MaximumDifference)
        require(playerObj.position.y - expectedY < MaximumDifference)

suite "Raycasting: Horizontal Intersections":
    setup:
        let mapData =  "101\n020\n101".stringToWorldMap()
        let playerObj = player.ctor(mapData)

    test "Horizontal Intersection is (1.5, 0.9999..) when centered / facing North":
        let intersect = getHorizontalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        checkpoint("Intersect should be (1.5, 0.9999...)")
        require(abs(intersect.x - playerObj.position.x) < MaximumDifference)
        require(1 - (intersect.y + AlmostZero) < MaximumDifference) # (1 - (0.999 + 0.0001)) < 0.0001

    test "Horizontal Intersection is (1.5, 2.0001) when centered / facing South":
        checkpoint("Rotate player to face south")
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 180.0f.degToRad())

        checkpoint("Intersect should be (1.5, 2.0001...)")
        let intersect = getHorizontalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(abs(1.5f - intersect.x) < MaximumDifference)
        require(abs(2.0f + AlmostZero - intersect.y) < MaximumDifference)

    test "Horizontal Intersection is (smallValue, 0) when facing completely left":
        let smallKnownValue = -10_000.0f

        checkpoint("Rotating 90 degrees to the left")
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad())

        checkpoint("Intersect should be (-verySmallValue, 2.0001...)")
        let intersect = getHorizontalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(intersect.x < smallKnownValue)
        require(abs(2.0f + AlmostZero - intersect.y) < MaximumDifference)

    test "Horizontal Intersection is (largeValue, 0) when facing centered / completely right":
        let largeValue = 10_000.0f

        checkpoint("Rotating 90 degrees to the right")
        playerObj.move(Direction.Right, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad())

        checkpoint("Intersect should be (LargeValue, 2.0001...)")
        let intersect = getHorizontalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(intersect.x > largeValue)
        require(abs(2.0f + AlmostZero - intersect.y) < MaximumDifference)

suite "Raycasting: Vertical Intersections":

    setup:
        let mapData =  "101\n020\n101".stringToWorldMap()
        let playerObj = player.ctor(mapData)

    test "Vertical Intersection is (2.0001..., 1.5) when facing completely East":
        checkpoint("Rotating 90 degrees to the right")
        playerObj.move(Direction.Right, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad())
        let intersect = getVerticalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(abs(intersect.x - (2f + MaximumDifference)) < MaximumDifference)
        require(abs(intersect.y - 1.5f) < MaximumDifference)

    test "Vertical Intersection is (0.999..., 1.5) when facing completely West":
        checkpoint("Rotating 90 degrees to the left")
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 90.0f.degToRad())
        let intersect = getVerticalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(abs(1 - (intersect.x + MaximumDifference)) < MaximumDifference) # (1 - (0.999+ 0.001)) should be ~= 0
        require(abs(1.5f - intersect.y) < MaximumDifference)

    # TODO: Figure out why largeValues are when facing north and not small values
    test "Vertical Intersection is (1.5, largeValue) when facing completely North":
        let intersect = getVerticalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(abs(1 - (intersect.x + MaximumDifference)) < MaximumDifference)
        require(intersect.y > 0)
        require(intersect.y > LargeKnownValue)

    # TODO: Figure out why smallValues are when facing south and not largeValues
    test "Vertical Intersection is (1.5, largeValue) when facing completely South":
        checkpoint("Rotating 180 degrees to the south")
        playerObj.move(Direction.Left, true)
        playerObj.update(OneSecondDeltaTime, rotateSpeed = 180.0f.degToRad())
        let intersect = getVerticalIntersection(playerObj.position, playerObj.theta, AlmostZero)
        require(abs(intersect.x - (2f + MaximumDifference)) < MaximumDifference)
        require(intersect.y > 0)
        require(intersect.y > LargeKnownValue)

suite "Raycasting: Horizontal Raycasting Finds Walls":

    # Map looks like:
    #    |W|W|W|   W=Wall
    #    |0|0|0|   P=Player
    #    |W|P|W|   0=No Wall

    setup:
        let mapData =  "111\n000\n121".stringToWorldMap()
        let playerObj = player.ctor(mapData)

    test "Spawn in center of map cell (1.5, 2.5f)":
        check(playerObj.position == vec2f(1.5, 2.5))

    test "Map cell (1, 0) is closest horizontal boundary with distance d=2.5m":
        let
            firstHorizontalPoint = getHorizontalIntersection(playerObj.position, playerObj.theta, AlmostZero)
            firstHorizontalWall = horizontalRaycast(playerObj.position, firstHorizontalPoint, playerObj.theta, mapData, AlmostZero)
            expectedDistance = 2.549509f

        checkpoint("firstHorizontalPoint should be (1.5, 1.999...) ")
        require(abs(firstHorizontalPoint.x - 1.5) < MaximumDifference)
        require(abs(2.0f - (firstHorizontalPoint.y + MaximumDifference)) < MaximumDifference)

        checkpoint("firstHorizontalWall should be ~2.5 meters infront of us")
        require(abs(expectedDistance - firstHorizontalWall) < MaximumDifference)