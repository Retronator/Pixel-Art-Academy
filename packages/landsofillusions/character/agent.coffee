AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
RA = Retronator.Accounts

# A wrapper around a character instance that represents a character from a player.
class LOI.Character.Agent extends LOI.Character.Person
  @id: -> 'LandsOfIllusions.Character.Agent'

  @fullName: -> "Person"
  @description: -> "It's _person_."

  @translations: ->
    yourCharacter: "It's your character."

  @initialize()
  
  constructor: (@_id) ->
    super arguments...

    # All agents are (potential) students.
    @require PixelArtAcademy.Student

    # Agent's main avatar will be the character avatar from the instance, so we manually create the avatar based on
    # this thing. This way we can use some universal avatar values that hold for all agents (like description).
    @thingAvatar = @avatar

    # We override the main avatar to be the instance's avatar.
    @instance = LOI.Character.getInstance @_id
    @avatar = @instance.avatar

    # Subscribe to the memory of the action the person is performing.
    @_actionSubscription = Tracker.autorun (computation) =>
      # See if this action even is inside a memory.
      return unless action = @action()
      return unless action.memory
      
      LOI.Memory.forId.subscribe action.memory._id

    # Agent state needs to be stored in a special sub-field since the thing state is one across all agents.
    @personStateAddress = new LOI.StateAddress "people.#{@_id}"
    @personState = new LOI.StateObject address: @personStateAddress

  ready: ->
    conditions = [
      super arguments...
      @thingAvatar.ready()
      @instance.ready()
    ]

    _.every conditions

  description: ->
    if @_id is LOI.characterId()
      @translations().yourCharacter

    else
      LOI.Character.formatText @thingAvatar.description(), 'person', @instance

  # Actions

  subscribeRecentActions: ->
    LOI.Memory.Action.recentForCharacter.subscribe @_id, @recentActionsEarliestTime()

  subscribeRecentMemories: ->
    actions = @_recentActions()
    memoryIds = _.uniq (action.memory._id for action in actions when action.memory)

    LOI.Memory.forIds.subscribe memoryIds

  recentActions: ->
    # Automatically subscribe to actions. We assume this is asked from a reactive 
    # computation so the subscription will stop when computation ends.
    @subscribeRecentActions()
    
    # Return the actions.
    @_recentActions()
    
  _recentActions: ->
    LOI.Memory.Action.documents.fetch
      'character._id': @_id
      time: $gte: @recentActionsEarliestTime()

  getActions: (query) ->
    LOI.Memory.Action.documents.fetch _.extend {}, query,
      'character._id': @_id
