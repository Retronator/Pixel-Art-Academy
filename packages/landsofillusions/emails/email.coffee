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

  isVisible: -> false

  # Override to return the game date when the email was sent.
  gameDate: ->

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
