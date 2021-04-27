LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Learning.Task.Entry.Action extends LOI.Memory.Action
  # content: extra information defining what was done in this action, specified in inherited actions
  #   taskEntry: array with one task entry this action created, reverse of Learning.Task.Entry.action
  #     _id
  #     taskId
  @type: 'PixelArtAcademy.Learning.Task.Entry.Action'
  @register @type, @

  @isMemorable: -> true

  @startDescription: ->
    "_person_ smiles as _they_ complete_s one of the learning tasks."

  shouldSkipTransition: (oldAction) ->
    # Skip if we're transitioning from another entry action.
    oldAction?.type is @type
