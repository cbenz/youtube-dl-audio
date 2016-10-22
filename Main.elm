module Main exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (href, src, controls, placeholder, style, download)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import String
import Task


initialUrl : String
initialUrl =
    "https://www.youtube.com/watch?v=3VHUpGxFJJ8"


main : Program Never
main =
    Html.App.program
        { init = ( { url = initialUrl, downloading = False, audioUrl = "", errorMsg = "" }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }


type alias Url =
    String


type alias Model =
    { url : String
    , downloading : Bool
    , audioUrl : String
    , errorMsg : String
    }


type Msg
    = ConvertIt
    | InputChanged String
    | FetchError Http.Error
    | FetchSuccess String


view : Model -> Html Msg
view model =
    div [ style [ ( "margin", "1em" ) ] ]
        ([ input
            [ onInput InputChanged
            , placeholder initialUrl
            , style [ ( "width", "70%" ) ]
            ]
            []
         , button [ onClick ConvertIt ] [ text "Ok" ]
         , br [] []
         , audio [ src model.audioUrl, controls True ] []
         , br [] []
         , a [ href model.audioUrl, download True ] [ text "Download" ]
         , br [] []
         ]
            ++ (if model.downloading then
                    [ text "Downloading" ]
                else if not (String.isEmpty model.errorMsg) then
                    [ text "Oh no :(" ]
                else
                    []
               )
            ++ [ footer [ style [ ( "position", "absolute" ), ( "bottom", "0" ) ] ]
                    [ p []
                        [ text "This is free software, source code on "
                        , a [ href "https://github.com/cbenz/youtube-dl-audio" ] [ text "GitHub" ]
                        ]
                    ]
               ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged text ->
            ( { model | url = text }, Cmd.none )

        ConvertIt ->
            ( { model | downloading = True }, getAudio model.url )

        FetchError _ ->
            ( { model | errorMsg = "oops", downloading = False }, Cmd.none )

        FetchSuccess url ->
            ( { model | downloading = False, audioUrl = url }, Cmd.none )


getAudio : String -> Cmd Msg
getAudio url =
    let
        task =
            Http.get
                (Json.Decode.at [ "info", "url" ] Json.Decode.string)
                ("http://youtube-dl.appspot.com/api/info?format=bestaudio&url=" ++ url)
    in
        Task.perform FetchError FetchSuccess task
