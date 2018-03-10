AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Hand extends AM.Component
  @id: -> 'LandsOfIllusions.Components.Hand'
  @register @id()

  @version: -> '0.1.0'

  handStyle: ->
    if character = LOI.character()
      shade = _.clamp character.avatar.body.properties.skin.shade(), 3, 8

    else
      shade = 5

    url = "/landsofillusions/components/hand/hand-shade#{shade}.png"

    backgroundImage: "url(#{@versionedUrl url})"
