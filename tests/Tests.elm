module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String
import Phoenix.Internal.ChannelTest


all : Test
all =
    describe "elm-phoenix"
        [ Phoenix.Internal.ChannelTest.all
        ]
