AM = Artificial.Mirage
AB = Artificial.Base
City = Retropolis.City

class City.Layouts.City extends AM.Component
  @register 'Retropolis.City.Layouts.City'

  @title: (options) ->
    "Retropolis — City of Dreams"

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 320
      minScale: 2

    $('html').addClass('retropolis-city')

  onDestroyed: ->
    super

    $('html').removeClass('retropolis-city')
