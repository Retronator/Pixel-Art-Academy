LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Emails.Email extends LOI.Adventure.Thing
  @id: -> 'LandsOfIllusions.Emails.Email'
  @fullName: -> "email"
  @description: ->
    "
      It's an email.
    "

  constructor: (data) ->
    super

    @arrived = new ComputedField =>
      gameTime = LOI.adventure.gameTime()
      emailTime = @gameTime()

      # Admission email has arrived if current game time is after the email was sent.
      gameTime?.getTime() > emailTime?.getTime()
    ,
      true

  destroy: ->
    super

    @arrived.stop()

  isVisible: -> false

  # Override to return the game date when the email was sent.
  gameTime: ->

  # Get who sent this email. Returns:
  #   {character}: the character instance who sent this email or null if it was a direct email
  #     or
  #   {name, address}: direct name and address of the sender or null if the sender was a character
  sender: ->

  # Get who received this email. Returns:
  #   {character}: the character instance who sent this email or null if it was a direct email
  #     or
  #   {name, address}: direct name and address of the sender or null if the sender was a character
  recipient: ->

  # Get the subject line string.
  subject: ->

  # Get the body of the email. Returns:
  #   html: html version of the body
  #   text: plain text version of the body
  body: ->

  from: -> @_getName @sender()
  to: -> @_getName @recipient()

  _getName: (info) ->
    info?.name or info?.character?.avatar.fullName()

  wasRead: ->
    @state 'read'
    
  markAsRead: (value = true) ->
    @state 'read', value

    # Also disable notifications for this email.
    @markAsNotified() if value

  wasNotified: ->
    @state 'notified'

  markAsNotified: ->
    @state 'notified', true
