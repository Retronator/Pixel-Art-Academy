PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.RandomNotificationsProvider extends PAA.PixelPad.Systems.Notifications.Provider
  @id: -> "PixelArtAcademy.LearnMode.RandomNotificationsProvider"
  @initialize()
  
  @notificationIds = []
  
  @registerNotificationClass: (notificationClass) ->
    @notificationIds.push notificationClass.id()
  
  availableNotificationIds: ->
    @_randomNotifications ?= _.shuffle(@constructor.notificationIds).slice 0, 3
    @_randomNotifications
