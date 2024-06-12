AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Notifications.Notification
  @DisplayStyles =
    OnDemand: 'OnDemand'
    IfIdle: 'IfIdle'
    Always: 'Always'
  
  @_notificationClassesById = {}
  
  @id: -> throw new AE.NotImplementedException "You must specify notification's id."
  
  @getClassForId: (id) ->
    @_notificationClassesById[id]
    
  @message: -> null
  
  @priority: -> 0
  
  @displayStyle: ->
    # Override if you want the notification to display proactively.
    @DisplayStyles.OnDemand
    
  @initialize: ->
    # Store notification class by ID.
    @_notificationClassesById[@id()] = @
    
    # On the server, after document observers are started, perform initialization.
    if Meteor.isServer
      Document.startup =>
        return if Meteor.settings.startEmpty

        # Create this notification's translated names.
        translationNamespace = @id()
        
        for property in ['message']
          continue unless value = @[property]()
          AB.createTranslation translationNamespace, property, value
          
  constructor: ->
    translationNamespace = @id()
    @_translationSubscription = AB.subscribeNamespace translationNamespace
    
    @lastDisplayedTime = new ReactiveField null
  
  destroy: ->
    @_translationSubscription.stop()
    
  id: -> @constructor.id()

  message: -> AB.translate(@_translationSubscription, 'message').text
  messageTranslation: -> AB.translation @_translationSubscription, 'message'
  
  priority: -> @constructor.priority()
  displayStyle: -> @constructor.displayStyle()
  
  updateLastDisplayedTime: ->
    @lastDisplayedTime new Date()
