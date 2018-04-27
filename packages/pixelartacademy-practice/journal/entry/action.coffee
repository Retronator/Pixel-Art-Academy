AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions
PADB = PixelArtDatabase

Nodes = LOI.Adventure.Script.Nodes
Vocabulary = LOI.Parser.Vocabulary

class PAA.Practice.Journal.Entry.Action extends LOI.Memory.Action
  # content: extra information defining what was done in this action, specified in inherited actions
  #   journalEntry: array with one journal entry this action created, reverse of Journal.Entry.action
  #     _id
  #     journal
  #       _id
  #       character
  #         _id
  #         avatar
  #           fullName
  #           color
  @type: 'PixelArtAcademy.Practice.Journal.Entry.Action'
  @register @type, @

  @isMemorable: -> true

  @startDescription: ->
    "_person_ starts writing in _their_ journal."

  @activeDescription: ->
    "_They_ _are_ writing in _their_ ![journal](read _person_'s journal)."

  shouldSkipTransition: (oldAction) ->
    # Skip if we're transitioning from another entry action.
    oldAction?.type is @type
