#
# player.nim
# Author: Samuel Vargas
#

import glm
import units

const
    WalkingSpeed: Meter = 1.4
    #discard TurnSpeed: Meter = WalkingSpeed / 2

type Player = ref object of RootObj
    position: Vec3f
    forward: Vec3f
    rotation: Vec3f

proc ctor*(): Player =
    result = Player();
    result.position = vec3f(0, 0, 0)
    result.forward = vec3f(0, 0, -1)
    result.rotation = vec3f(0, 0, 0)

method move*(this: Player, direction: Direction): void {.base.} =
    case direction:
        of Forward:
            this.position.z += WalkingSpeed
        of Backward:
            this.position.z -= WalkingSpeed
        else:
            discard


method position*(this: Player): Vec3f {.base.} =
    this.position
