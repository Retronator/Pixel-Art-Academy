AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
Studio = SanFrancisco.Apartment.Studio

class Studio.Computer.Email extends AM.Component
  @register 'SanFrancisco.Apartment.Studio.Computer.Email'

  constructor: (@computer) ->
    super arguments...

  onCreated: ->
    super arguments...

    @inboxLocation = new LOI.Emails.Inbox()

    @currentInbox = new ComputedField =>
      new LOI.Adventure.Situation
        location: @inboxLocation
        timelineId: LOI.adventure.currentTimelineId()

    @selectedEmail = new ReactiveField null

  appId: -> 'email'
  name: -> 'Inbox'
    
  backButtonCallback: ->
    @computer.switchToScreen @computer.screens.desktop

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true

  emails: ->
    @currentInbox().things()

  selectedClass: ->
    email = @currentData()
    'selected' if email is @selectedEmail()
    
  readClass: ->
    email = @currentData()
    'read' if email.wasRead()

  events: ->
    super(arguments...).concat
      'click .email': @onClickEmail

  onClickEmail: (event) ->
    email = @currentData()
    @selectedEmail email
    email.markAsRead()
