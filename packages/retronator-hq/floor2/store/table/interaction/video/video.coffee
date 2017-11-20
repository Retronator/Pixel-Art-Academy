AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction.Video extends HQ.Store.Table.Interaction
  @register 'Retronator.HQ.Store.Table.Interaction.Video'

  constructor: (@player) ->
    super

    @_illustrationHeight = new ReactiveField 150

  onCreated: ->
    super

    # Search for the first parent that has a display.
    parentWithDisplay = @ancestorComponentWith 'display'
    @display = parentWithDisplay.display

  onRendered: ->
    super

  illustrationHeight: ->
    @_illustrationHeight()

  playerEmbed: ->
    _.last(@player).embed_code
