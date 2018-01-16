#
# units.nim
# Author: Samuel Vargas
#

type
    Meter* = float32

type
    Pixels* = int

type
    Direction* = enum
        Forward,
        Backward,

type
    Rotation* = enum
        Left,
        Right