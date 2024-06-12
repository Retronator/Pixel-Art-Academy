AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Notifications extends PAA.PixelPad.System
  @id: -> 'PixelArtAcademy.PixelPad.Systems.Notifications'
  
  @version: -> '0.1.0'
  
  @register @id()
  template: -> @constructor.id()
  
  @fullName: -> "Notifications"
  @description: ->
    "
      A non-intrusive notification system.
    "
  
  @initialize()
  
  onCreated: ->
    super arguments...
  
    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @
    
    @providers = for providerClass in PAA.PixelPad.Systems.Notifications.Provider.getClasses()
      new providerClass @
      
    @_notifications = {}
  
    @availableNotifications = new ComputedField =>
      availableNotifications = []
      
      for provider in @providers
        for notificationId in provider.availableNotificationIds()
          unless @_notifications[notificationId]
            notificationClass = PAA.PixelPad.Systems.Notifications.Notification.getClassForId notificationId
            @_notifications[notificationId] = new notificationClass
            
          notification = @_notifications[notificationId]
          availableNotifications.push notification unless notification in availableNotifications
      
      availableNotifications
      
    @unreadNotifications = new ReactiveField []
    @displayedNotification = new ReactiveField null
    @readNotifications = new ReactiveField []
    
    @homeScreenActive = new ComputedField => not @os.currentAppUrl()
    
    # Whenever available notifications change, add the new ones to unread.
    @autorun (computation) =>
      return unless @homeScreenActive()
      availableNotifications = @availableNotifications()
      
      Tracker.nonreactive =>
        unreadNotifications = @unreadNotifications()
        
        existingNotifications = [
          unreadNotifications...
          @displayedNotification()
          @readNotifications()...
        ]
        
        for notification in availableNotifications when notification not in existingNotifications
          unreadNotifications.push notification
        
        @unreadNotifications unreadNotifications
    
    # Listen for the home app to be displayed and display a notification.
    @autorun (computation) =>
      unless @homeScreenActive()
        # Close existing notifications.
        Tracker.nonreactive => @closeDisplayedNotification()
        return
        
      Meteor.setTimeout =>
        toDo = @os.getSystem PAA.PixelPad.Systems.ToDo
        
        if toDo.isActive()
          # To-do is active, wait until it's inactive and display any unread notifications that should always show.
          await toDo.waitUntilInactive()
          
          # Give a moment before the notification displays.
          await _.waitForSeconds 0.5
          
          # Make sure we should still show the notification after waiting.
          return unless @_shouldDisplayNotification()
          
          @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.Always
          
        else
          # Give a moment before the notification displays.
          await _.waitForSeconds 1
          
          # Make sure we should still show the notification after waiting.
          return unless @_shouldDisplayNotification()
          
          # To-do didn't have the show, give idle unread notification a chance if there is no always ones.
          return if @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.Always
          @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.IfIdle
      ,
        500
      
  _shouldDisplayNotification: ->
    # Make sure we're still on the home screen.
    return unless @homeScreenActive()
    
    # Make sure a notification wasn't shown manually.
    return if @displayedNotification()
    
    true
    
  onRendered: ->
    super arguments...
    
    # Close the message when clicking.
    $(document).on 'click.pixelartacademy-pixelpad-systems-notifications', (event) =>
      return if $(event.target).closest('.retro').length
      
      @closeDisplayedNotification()

  onDestroyed: ->
    super arguments...
    
    notification.destroy() for notificationId, notification of @_notifications
  
    @app.removeComponent @
    
    $(document).off '.pixelartacademy-pixelpad-systems-notifications'
    
  dontRender: -> true
  
  _displayUnreadNotificationWithDisplayStyle: (displayStyle) ->
    unreadNotifications = @unreadNotifications()
    validNotifications = _.filter unreadNotifications, (notification) => notification.displayStyle() is displayStyle

    # Choose the notification with top priority.
    sortedNotifications = _.sortBy validNotifications, (notification) => notification.priority()
    topNotification = _.last sortedNotifications
    
    return false unless topNotification

    _.pull unreadNotifications, topNotification
    @unreadNotifications unreadNotifications

    @displayedNotification topNotification

    true
  
  displayNewNotification: ->
    notificationWasDisplayed = @displayedNotification()
    
    # Close existing notifications.
    @closeDisplayedNotification()
    
    # Try to display any unread notifications, from most to least important.
    return if @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.Always
    return if @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.IfIdle
    return if @_displayUnreadNotificationWithDisplayStyle @constructor.Notification.DisplayStyles.OnDemand
    
    # No unread notifications were found, cycle through read ones.
    readNotifications = @readNotifications()
    
    # If we only have read notifications and one was already displayed, don't reopen it again.
    return if notificationWasDisplayed and readNotifications.length is 1
    
    sortedNotifications = _.sortBy readNotifications, (notification) => notification.lastDisplayedTime()
    oldestNotification = _.first sortedNotifications
    
    _.pull readNotifications, oldestNotification
    @readNotifications readNotifications
    
    @displayedNotification oldestNotification
    
    true
  
  closeDisplayedNotification: ->
    return unless displayedNotification = @displayedNotification()
    readNotifications = @readNotifications()
    
    displayedNotification.updateLastDisplayedTime()
    @displayedNotification null
    readNotifications.push displayedNotification
    
  speechBalloonOptions: ->
    text: => @displayedNotification()?.message()
  
  events: ->
    super(arguments...).concat
      'click .retro': @onClickRetro
  
  onClickRetro: (event) ->
    @displayNewNotification()
