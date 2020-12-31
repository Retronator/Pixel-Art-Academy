LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory extends AM.Document
  @id: -> 'LandsOfIllusions.Memory'
  # actions: list of actions in this memory, reverse of action.memory (note: they are not automatically sorted by time)
  #   _id
  #   time
  #   character
  #     _id
  #     avatar
  #       fullName
  #       color
  #   type
  #   memory
  #     _id
  #   content
  # startTime: auto-generated time of the first action in this memory
  # endTime: auto-generated time of the last action in this memory
  # timelineId: timeline when the memory happened
  # locationId: location where the memory took place
  # contextId: optional context in which the memory started
  #
  # journalEntry: array with one journal entry this memory relates to, reverse of Journal.Entry.memories
  #   _id
  #   journal
  #     _id
  #     character
  #       _id
  #       avatar
  #         fullName
  #         color
  @Meta
    name: @id()
    fields: =>
      startTime: Document.GeneratedField 'self', ['actions'], (memory) ->
        return [memory._id, undefined] unless memory.actions?.length

        orderedActions = _.sortBy memory.actions, (action) -> action.time.getTime()

        [memory._id, orderedActions[0].time]

      endTime: Document.GeneratedField 'self', ['actions'], (memory) ->
        return [memory._id, undefined] unless memory.actions?.length

        orderedActions = _.sortBy memory.actions, 'time'

        [memory._id, _.last(orderedActions).time]

  # Methods

  @insert: @method 'insert'
  @getLastUndiscovered: @method 'getLastUndiscovered'

  # Subscriptions

  @all: @subscription 'all'
  @allWithActionsOfType: @subscription 'allWithActionsOfType'
  @forId: @subscription 'forId'
  @forIds: @subscription 'forIds'
  
  @forCharacter: @subscription 'forCharacter',
    query: (characterId, limit, skip) =>
      LOI.Memory.documents.find
        $or: [
          'actions.character._id': characterId
        ,
          'journalEntry.journal.character._id': characterId
        ]
      ,
        limit: limit
        skip: skip
        sort:
          endTime: -1

  constructor: ->
    super arguments...

    # Sort and cast actions, to get them in the form we'd expect.
    @actions = _.sortBy @actions, (action) => action.time.getTime()
    @actions = (action.cast() for action in @actions)

  display: ->
    # Create the context for this memory document and enter it. The context will already be displaying this memory.
    context = LOI.Memory.Context.createContext @
    LOI.adventure.enterContext context

  chronologicalActions: ->
    _.sortBy @actions, 'time'
