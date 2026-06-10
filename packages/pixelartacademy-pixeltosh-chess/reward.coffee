AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Reward
  @_rewardClasses = []
  
  @getClasses: -> @_rewardClasses
  
  # ID string for this reward used to identify the reward in code.
  @id: -> throw new AE.NotImplementedException "You must specify reward's id."

  # String to represent the reward in the UI. Note that we can't use
  # 'name' since it's an existing property holding the class name.
  @displayName: -> throw new AE.NotImplementedException "You must specify the reward name."
  
  @value: (data) -> throw new AE.NotImplementedException "You must specify how much currency a reward earns."
  
  @initialize: ->
    @_rewardClasses.push @
    
    @stateAddress = new LOI.StateAddress "things.#{@id()}"
    @state = new LOI.StateObject address: @stateAddress
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty
        
        # Create this reward's translated names.
        translationNamespace = @id()
        AB.createTranslation translationNamespace, property, @[property]() for property in ['displayName']
  
  constructor: (@rewardsManager) ->
    @stateAddress = @constructor.stateAddress
    @state = @constructor.state
    
    # Subscribe to this reward's translations.
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
  
  destroy: ->
    @_translationSubscription.stop()
  
  id: -> @constructor.id()
  value: (data) -> @constructor.value()
  
  displayName: -> AB.translate(@_translationSubscription, 'displayName').text
  displayNameTranslation: -> AB.translation @_translationSubscription, 'displayName'
  
  onLessonCompleted: -> # Override to perform any rewarding logic when a lesson is completed.

  reward: (data) ->
    reward = id: @id()
    reward.data = data if data
    
    pendingRewards = Chess.pendingRewards()
    pendingRewards.push reward
    Chess.pendingRewards pendingRewards
