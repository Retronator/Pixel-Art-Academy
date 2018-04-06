LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory.Action extends AM.Document
  @id: -> 'LandsOfIllusions.Memory.Action'
  # type: constructor type for inheritance
  # time: when this action was done
  # timelineId: timeline when the action was done
  # locationId: location where the action was done
  # contextId: optional context in which the action was done
  # character: character who did this action
  #   _id
  #   avatar
  #     fullName
  #     color
  # memory: optional memory this action belongs to.
  #   _id
  # content: extra information defining what was done in this action
  @type: @id()
  @register @type, @
  
  @Meta
    name: @id()
    fields: =>
      memory: @ReferenceField LOI.Memory, [], true, 'actions', ['time', 'character', 'type', 'content']
      character: @ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], false

  # A place for actions to add their content patterns.
  @contentPatterns = {}

  @registerContentPattern: (type, pattern) ->
    @contentPatterns[type] = pattern

  # Methods

  @do: @method 'do'
  @changeContent: @method 'changeContent'

  # Subscriptions

  @forMemory: @subscription 'forMemory'
  @recentForLocation: @subscription 'recentForLocation'
