LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

Vocabulary = LOI.Parser.Vocabulary

class Studio.EmailNotification extends LOI.Adventure.Thing
  @id: -> 'SanFrancisco.Apartment.Studio.EmailNotification'

  @fullName: -> "email notification"

  @description: ->
    "
      It's a notification that a new email has arrived.
    "

  @initialize()

  @defaultScriptUrl: -> 'retronator_sanfrancisco-apartment/studio/emailnotification.script'

  constructor: ->
    super

    @inboxLocation = new LOI.Emails.Inbox()

    # Listen to things in the inbox location.      
    @_updateAutorun = Tracker.autorun (computation) =>
      return unless @ready()
      
      # Don't send notification if not in the narrative.
      return unless LOI.adventure.interface.active()

      inbox = new LOI.Adventure.Situation
        location: @inboxLocation
        timelineId: LOI.adventure.currentTimelineId()

      unless _.every (email.wasNotified() for email in inbox.things())
        Tracker.nonreactive =>
          @listeners[0].startScript()

          for email in inbox.things() when not email.wasNotified()
            email.markAsNotified()

  destroy: ->
    super

    @_updateAutorun.stop()
