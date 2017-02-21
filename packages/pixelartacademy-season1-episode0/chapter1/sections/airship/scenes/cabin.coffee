LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Airship.Cabin extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Cabin'

  @location: -> RS.AirshipTerminal.Airship.Cabin

  @intro: -> "
    The interior of the airship is more like a spacious train carriage than a crammed airplane.
    The windows are generous in size as well. This will be one spectacular ride to the main island.
  "

  @initialize()

  things: ->
    [
      C1.Actors.Alex
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/airship/scenes/cabin.script'

  onEnter: (enterResponse) ->
    @setCurrentThings
      alex: C1.Actors.Alex
      table: RS.AirshipTerminal.Airship.Cabin.TableDisplay
    ,
      => @startScript()
