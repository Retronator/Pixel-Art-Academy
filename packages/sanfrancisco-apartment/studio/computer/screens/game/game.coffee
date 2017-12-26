AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Game extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Game'

  constructor: (@computer, @gameName) ->
    super

  onRendered: ->
    super

    @autorun (computation) =>
      display = @callAncestorWith 'display'

      embedWidth = 560
      targetWidth = 320 * display.scale()
      scale = targetWidth / embedWidth

      @$('.embed').css
        transform: "translate3d(-50%, -50%, 0) scale3d(#{scale}, #{scale}, 1)"

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop
