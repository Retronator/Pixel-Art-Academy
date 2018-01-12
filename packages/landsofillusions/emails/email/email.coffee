LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Emails.Email extends AM.Document
  @id: -> 'LandsOfIllusions.Emails.Email'
  # sender: who sent this email
  #   character: the character who sent this email or null if it was a direct email
  #     _id
  #     avatar
  #       fullName
  #   direct: direct email address of the sender or null if the sender was a character
  #     name
  #     address
  # recipient: who received this email
  #   character: the character who received this email or null if it was a direct email
  #     _id
  #     avatar
  #       fullName
  #   direct: direct email address of the recipient or null if the recipient is a character
  #     name
  #     address
  # subject: plain text of the subject line
  # body: the body of the email
  #   html: html version of the body
  #   text: plain text version of the body
  @Meta
    name: @id()
    fields: =>
      'sender.character': @ReferenceField LOI.Character, ['avatar.fullName'], false
      'recipient.character': @ReferenceField LOI.Character, ['avatar.fullName'], false

  # Methods

  @insert: @method 'insert'

  # Subscriptions

  @forCharacter: @subscription 'forCharacter'
