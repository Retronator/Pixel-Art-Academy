AM = Artificial.Mirage
AB = Artificial.Base
World = LandsOfIllusions.World

class World.Layouts.Center extends AM.Component
  @register 'LandsOfIllusions.World.Layouts.Center'

  @title: (options) ->
    "Lands of Illusions — Alternate Reality Center"
    
  onCreated: ->
    super

    $('html').addClass('landsofillusions-world-center')

  onDestroyed: ->
    super

    $('html').removeClass('landsofillusions-world-center')
