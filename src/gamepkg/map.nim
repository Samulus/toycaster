#
# map.nim
# Author: Samuel Vargas
#
# Creating 2D Sequences in Nim
# https://stackoverflow.com/a/30298951
#

import sdl2/sdl
import strutils
import ospaths
import options

type
    TileType* = enum
        Empty = 0
        Wall = 1
        Player = 2

type
    LevelMap* = seq[seq[TileType]]

proc assignTileTypeToNumber(value: char, tile: var TileType): bool =
    result = false
    let n = parseInt($value)
    result = n == 0 or n == 1 or n == 2

    if n == 0:
        tile = Empty
    elif n == 1:
        tile = Wall
    elif n == 2:
        tile = Player

proc stringToWorldMap*(data: string): LevelMap =
    result = newSeq[seq[TileType]]()
    var i = 0
    for line in data.splitLines():
        result.add(newSeq[TileType]())
        for ch in line:
            var tile: TileType
            assert(ch.assignTileTypeToNumber(tile), "Invalid Char: " & $ch)
            result[i].add(tile)
        i = i + 1

proc fileToWorldMap*(filePath: string): Option[LevelMap] =
    var file: File
    if not open(file, filePath, FileMode.fmRead):
        return none(LevelMap)

    var matrix = newSeq[seq[TileType]]()
    var line: string
    var i = 0

    while file.readLine(line):
        matrix.add(newSeq[TileType]())
        for ch in line:
            var tile: TileType
            assert(ch.assignTileTypeToNumber(tile), "Invalid Char: " & $ch)
            matrix[i].add(tile)
        i = i + 1

    return some(matrix)