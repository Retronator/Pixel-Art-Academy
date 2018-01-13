LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Emails.Email extends LOI.Adventure.Thing
  # realTime: real life time when the email was sent
  @id: -> 'LandsOfIllusions.Emails.Email'
  @fullName: -> "email"
  @description: ->
    "
      It's an email.
    "

  constructor: (data) ->
    super

  isVisible: -> false

  # Override to return the game time when the email was sent.
  gameTime: ->

  # Get who sent this email. Returns:
  #   {character}: the character instance who sent this email or null if it was a direct email
  #     or
  #   {name, address}: direct name and address of the sender or null if the sender was a character
  sender: ->

  # Get who received this email. Returns:
  #   {character}: the character instance who sent this email or null if it was a direct email
  #     or
  # {name, address}: direct name and address of the sender or null if the sender was a character
  recipient: ->

  # Get the subject line string.
  subject: ->

  # Get the body of the email. Returns:
  #   html: html version of the body
  #   text: plain text version of the body
  body: ->
