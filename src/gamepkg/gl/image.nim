#
# image.nim
# Author: Samuel Vargas
#

type RGBAImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]

type GrayImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]