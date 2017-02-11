LOI = LandsOfIllusions
C0 = PixelArtAcademy.Season1.Episode0.Chapter0
RS = Retropolis.Spaceport

class C0.Start.Terrace extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start.Terrace'

  @location: -> RS.AirportTerminal.Terrace

  @translations: ->
    intro: "
      You exit the Retropolis International Spaceport.
      A magnificent view of the city opens before you and you feel the adventure in the air.
      The terrace you're standing on connects back to the airport terminal in the south.
    "

  @listenerClasses: -> [
    @Listener
  ]

  @initialize()

  things: ->
    [
      C0.Start.Backpack unless C0.Start.Backpack.state 'inInventory'
    ]

  class @Listener extends LOI.Adventure.Listener
    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode0/chapter0/start/scenes/terrace.script'
    ]

    class @Scripts.Terrace extends LOI.Adventure.Script
      @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter0.Start.Terrace'
      @initialize()

    @initialize()

    onEnter: (enterResponse) ->
      return unless enterResponse.currentLocationClass is @options.parent.constructor.location()

      introductionDone = @options.parent.state 'introductionDone'

      return if introductionDone

      enterResponse.overrideIntroduction =>
        @options.parent.translations().intro

      @options.parent.state 'introductionDone', true

    onExitAttempt: (exitResponse) ->
      return unless exitResponse.currentLocationClass is @options.parent.constructor.location()

      hasBackpack = C0.Start.Backpack.state 'inInventory'
      return if hasBackpack

      LOI.adventure.director.startScript @scripts[@constructor.Scripts.Terrace.id()], label: 'LeaveWithoutBackpack'
      exitResponse.preventExit()
