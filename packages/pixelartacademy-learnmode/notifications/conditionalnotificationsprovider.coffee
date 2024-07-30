AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.ConditionalNotificationsProvider extends PAA.PixelPad.Systems.Notifications.Provider
  @id: -> "PixelArtAcademy.LearnMode.ConditionalNotificationsProvider"
  @initialize()
  
  @notificationClasses = []
  
  @registerNotificationClass: (notificationClass) ->
    @notificationClasses.push notificationClass
  
  availableNotificationIds: ->
    notificationIds = []
    
    for notificationClass in @constructor.notificationClasses when notificationClass.condition()
      notificationIds.push notificationClass.id()
    
    notificationIds

  class @ConditionalNotification extends PAA.PixelPad.Systems.Notifications.Notification
    @condition: -> throw new AE.NotImplementedException "A conditional notification must provide a condition when to display it."
