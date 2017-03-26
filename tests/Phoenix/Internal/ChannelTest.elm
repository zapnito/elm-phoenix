module Phoenix.Internal.ChannelTest exposing (all)

import Test exposing (..)
import Expect
import Phoenix.Internal.Channel as InternalChannel exposing (InternalChannel)
import Dict
import Phoenix.Channel as Channel


users =
    { topic = "users"
    , channel = Channel.init "users"
    }


projects =
    { topic = "projects"
    , channel = Channel.init "projects"
    }


messages =
    { topic = "messages"
    , channel = Channel.init "messages"
    }


all =
    describe "InternalChannel"
        [ describe "dictStatusDiff"
            [ dictStatusDiffTest "both empty"
                { previous = []
                , next = []
                , expectedDiff = []
                }
            , dictStatusDiffTest "no change in a single channel"
                { previous = [ ( users.topic, InternalChannel InternalChannel.Joined users.channel ) ]
                , next = [ ( users.topic, InternalChannel InternalChannel.Joined users.channel ) ]
                , expectedDiff = []
                }
            , dictStatusDiffTest "change in a single channel"
                { previous = [ ( users.topic, InternalChannel InternalChannel.Closed users.channel ) ]
                , next = [ ( users.topic, InternalChannel InternalChannel.Joined users.channel ) ]
                , expectedDiff = [ ( users.topic, InternalChannel.Joined ) ]
                }
            , dictStatusDiffTest "remove a single channel"
                { previous = [ ( users.topic, InternalChannel InternalChannel.Closed users.channel ) ]
                , next = []
                , expectedDiff = [ ( users.topic, InternalChannel.Disconnected ) ]
                }
            , dictStatusDiffTest "add a single channel"
                { previous = []
                , next = [ ( users.topic, InternalChannel InternalChannel.Closed users.channel ) ]
                , expectedDiff = [ ( users.topic, InternalChannel.Closed ) ]
                }
            , dictStatusDiffTest "multiple changes"
                { previous =
                    [ ( users.topic, InternalChannel InternalChannel.Closed users.channel )
                    , ( projects.topic, InternalChannel InternalChannel.Closed projects.channel )
                    ]
                , next =
                    [ ( users.topic, InternalChannel InternalChannel.Errored users.channel )
                    , ( messages.topic, InternalChannel InternalChannel.Joining users.channel )
                    ]
                , expectedDiff =
                    [ ( users.topic, InternalChannel.Errored )
                    , ( projects.topic, InternalChannel.Disconnected )
                    , ( messages.topic, InternalChannel.Joining )
                    ]
                }
            ]
        ]


dictStatusDiffTest name { previous, next, expectedDiff } =
    test name <|
        \() ->
            Expect.equal
                (InternalChannel.dictStatusDiff (Dict.fromList previous) (Dict.fromList next))
                expectedDiff
