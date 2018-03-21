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

    @selectedEmail = new ReactiveField null

  appId: -> 'email'
  name: -> 'Inbox'

  emails: ->
    @currentInbox().things()

  selectedClass: ->
    email = @currentData()
    'selected' if email is @selectedEmail()

  events: ->
    super.concat
      'click .email': @onClickEmail

  onClickEmail: (event) ->
    email = @currentData()
    @selectedEmail email