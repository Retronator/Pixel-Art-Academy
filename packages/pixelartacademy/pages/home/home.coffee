AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pages.Home extends AM.Component
  @register 'PixelArtAcademy.Pages.Home'

  onCreated: ->
    super

  events: ->
    super.concat
      'click .enter-button': @onClickEnterButton

  onClickEnterButton: (event) ->
    PAA.Adventure.goToLocation 'dorm'
