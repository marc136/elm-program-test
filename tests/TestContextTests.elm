module TestContextTests exposing (all)

import Expect
import Html exposing (Html)
import Html.Events exposing (onClick)
import Json.Decode
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import TestContext exposing (TestContext)


testInit : String
testInit =
    "<INIT>"


testUpdate : String -> String -> ( String, Cmd msg )
testUpdate msg model =
    ( model ++ ";" ++ msg
    , Cmd.none
    )


testView : String -> Html String
testView model =
    Html.div []
        [ Html.span [] [ Html.text model ]
        , Html.button [ onClick "CLICK" ] [ Html.text "Click Me" ]
        ]


testContext : TestContext String String
testContext =
    TestContext.create
        { init = testInit
        , update = testUpdate
        , view = testView
        }


all : Test
all =
    describe "TestContext"
        [ test "has initial model" <|
            \() ->
                testContext
                    |> TestContext.expectModel (Expect.equal "<INIT>")
                    |> TestContext.done
        , test "can send a msg" <|
            \() ->
                testContext
                    |> TestContext.update "A"
                    |> TestContext.expectModel (Expect.equal "<INIT>;A")
                    |> TestContext.done
        , test "can click a button" <|
            \() ->
                testContext
                    |> TestContext.clickButton "Click Me"
                    |> TestContext.expectModel (Expect.equal "<INIT>;CLICK")
                    |> TestContext.done
        , test "can create with flags" <|
            \() ->
                TestContext.createWithFlags
                    { init = \flags -> "<INIT:" ++ flags ++ ">"
                    , update = testUpdate
                    , view = testView
                    }
                    "flags"
                    |> TestContext.expectModel (Expect.equal "<INIT:flags>")
                    |> TestContext.done
        , test "can create with navigation" <|
            \() ->
                TestContext.createWithNavigation
                    .pathname
                    { init = \location -> "<INIT:" ++ location.pathname ++ ">"
                    , update = testUpdate
                    , view = testView
                    }
                    "https://example.com/path"
                    |> TestContext.expectModel (Expect.equal "<INIT:/path>")
                    |> TestContext.done
        , test "can simulate a route change" <|
            \() ->
                TestContext.createWithNavigation
                    .pathname
                    { init = \location -> "<INIT:" ++ location.pathname ++ ">"
                    , update = testUpdate
                    , view = testView
                    }
                    "https://example.com/path"
                    |> TestContext.routeChange "https://example.com/new"
                    |> TestContext.expectModel (Expect.equal "<INIT:/path>;/new")
                    |> TestContext.done
        , test "can create with navigation and flags" <|
            \() ->
                TestContext.createWithNavigationAndFlags
                    .pathname
                    { init = \flags location -> "<INIT:" ++ location.pathname ++ ":" ++ flags ++ ">"
                    , update = testUpdate
                    , view = testView
                    }
                    "https://example.com/path"
                    "flags"
                    |> TestContext.expectModel (Expect.equal "<INIT:/path:flags>")
                    |> TestContext.done
        , test "can assert on the view" <|
            \() ->
                testContext
                    |> TestContext.shouldHaveView
                        (Query.find [ Selector.tag "span" ] >> Query.has [ Selector.text "<INIT>" ])
                    |> TestContext.done
        , test "can create with navigation and JSON string flags" <|
            \() ->
                TestContext.createWithNavigationAndJsonStringFlags
                    (Json.Decode.field "x" Json.Decode.string)
                    .pathname
                    { init = \flags location -> "<INIT:" ++ location.pathname ++ ":" ++ flags ++ ">"
                    , update = testUpdate
                    , view = testView
                    }
                    "https://example.com/path"
                    """{"x": "fromJson"}"""
                    |> TestContext.expectModel (Expect.equal "<INIT:/path:fromJson>")
                    |> TestContext.done
        , test "can assert on the view concisely given Html.Test.Selectors" <|
            \() ->
                testContext
                    |> TestContext.shouldHave [ Selector.tag "span" ]
                    |> TestContext.done
        , test "can assert on the view concisely given Html.Test.Selectors that should not exist" <|
            \() ->
                testContext
                    |> TestContext.shouldNotHave [ Selector.tag "article" ]
                    |> TestContext.done
        ]
