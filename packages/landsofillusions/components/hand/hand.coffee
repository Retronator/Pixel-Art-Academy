AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Hand extends AM.Component
  @id: -> 'LandsOfIllusions.Components.Hand'
  @register @id()

  @version: -> '0.1.0'

  showHand: ->
    # Only show hand for characters since we don't want to assume skin color.
    LOI.characterId?()

  handStyle: ->
    data = @data()
    style = if _.isString data then data else 'normal'

    character = LOI.character()
    shade = _.clamp character.avatar.body.properties.skin.shade(), 3, 8

    url = "/landsofillusions/components/hand/#{style}/shade#{shade}.png"

    backgroundImage: "url('#{@versionedUrl url}')"
