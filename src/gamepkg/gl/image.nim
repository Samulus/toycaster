#
# image.nim
# Author: Samuel Vargas
#

import easygl

type RGBAImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]

type GrayImage* = ref object of RootObj
    width*: uint
    height*: uint
    bytes*: seq[uint8]
    format*: TextureInternalFormat