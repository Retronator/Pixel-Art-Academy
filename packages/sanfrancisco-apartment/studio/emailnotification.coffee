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
    super arguments...

    @inboxLocation = new LOI.Emails.Inbox()

    # Listen to things in the inbox location.      
    @_updateAutorun = Tracker.autorun (computation) =>
      return unless @ready()
      
      # Don't send notification if not in the narrative.
      return unless LOI.adventure.interface.active()

      inbox = new LOI.Adventure.Situation
        location: @inboxLocation
        timelineId: LOI.adventure.currentTimelineId()

      # TODO: Remove debug output after fixing double notifications.
      console.log "Checking inbox"
      console.log "not?", email.wasNotified(), email for email in inbox.things()

      unless _.every (email.wasNotified() for email in inbox.things())
        Tracker.nonreactive =>
          @listeners[0].startScript()

          console.log "email ping"
          console.log "not?", email.wasNotified(), email for email in inbox.things()

          for email in inbox.things() when not email.wasNotified()
            console.log "marking email", email
            email.markAsNotified()

        console.log "done notifs"

  destroy: ->
    super arguments...

    @_updateAutorun.stop()
