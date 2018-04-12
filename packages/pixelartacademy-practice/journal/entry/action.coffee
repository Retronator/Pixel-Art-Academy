AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions
PADB = PixelArtDatabase

Nodes = LOI.Adventure.Script.Nodes
Vocabulary = LOI.Parser.Vocabulary

class PAA.Practice.Journal.Entry.Action extends LOI.Memory.Action
  @type: 'PixelArtAcademy.Practice.Journal.Entry.Action'
  @register @type, @

  @isMemorable: -> true

  @startDescription: ->
    "_person_ starts writing in _their_ journal."

  @activeDescription: ->
    "_They_ _are_ writing in _their_ journal."

  shouldSkipTransition: (oldAction) ->
    # Skip if we're transitioning from another entry action.
    oldAction.type is @type
