LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory extends AM.Document
  @id: -> 'LandsOfIllusions.Memory'
  # actions: list of actions in this memory, reverse of action.memory
  #   _id
  #   time
  #   character
  #     _id
  #     avatar
  #       fullName
  #       color
  #   type
  #   content
  # startTime: auto-generated time of the first action in this memory
  # endTime: auto-generated time of the last action in this memory
  #
  # journalEntry: array with one journal entry this memory relates to, reverse of Journal.Entry.memories
  #   _id
  #   character
  #     _id
  #     avatar
  #       fullName
  #       color
  @Meta
    name: @id()
    fields: =>
      startTime: @GeneratedField 'self', ['actions'], (memory) ->
        return [memory._id, undefined] unless memory.actions?.length

        orderedActions = _.sortBy memory.actions, (action) -> action.time.getTime()

        [memory._id, orderedActions[0].time]

      endTime: @GeneratedField 'self', ['actions'], (memory) ->
        return [memory._id, undefined] unless memory.actions?.length

        orderedActions = _.sortBy memory.actions, 'time'

        [memory._id, _.last(orderedActions).time]

  # Methods

  @insert: @method 'insert'

  # Subscriptions

  @forId: @subscription 'forId'
  @forCharacter: @subscription 'forCharacter'
