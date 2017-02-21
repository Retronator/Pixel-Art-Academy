LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Immigration extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration'

  @scenes: -> [
    @Concourse
    @Immigration
    @BaggageClaim
    @Customs
  ]

  @finished: ->
    # Immigration section is over when the player has left the customs. Make sure we don't return undefined though.
    @state('leftCustoms') is true

  @initialize()

  active: ->
    @requireFinishedSections C1.Start

  onExit: (exitResponse) ->
    return unless exitResponse.currentLocationClass is RS.AirportTerminal.Customs
    super

    # Mark the goal condition when the player exits the customs.
    @options.parent.state 'leftCustoms', true
