AE = Artificial.Everywhere
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.TaskNotificationsProvider extends PAA.PixelPad.Systems.Notifications.Provider
  @id: -> "PixelArtAcademy.LearnMode.TaskNotificationsProvider"
  @initialize()
  
  availableNotificationIds: ->
    notificationIds = []
    
    # See if any of the active tasks provides a notification.
    for chapter in LOI.adventure.currentChapters()
      for task in chapter.tasks when task.active() and task.activeNotificationId
        notificationIds.push task.activeNotificationId()

    notificationIds
