AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Email extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Email'

  constructor: (@computer) ->
    super

  onCreated: ->
    super

    @inboxLocation = new LOI.Emails.Inbox()

    @currentInbox = new ComputedField =>
      new LOI.Adventure.Situation
        location: @inboxLocation
        timelineId: LOI.adventure.currentTimelineId()

  emails: ->
    @currentInbox().things()

  events: ->
    super.concat
      'click .close-button': @onClickCloseButton

  onClickCloseButton: (event) ->
    @computer.switchToScreen @computer.screens.desktop
