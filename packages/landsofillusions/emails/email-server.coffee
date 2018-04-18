AB = Artificial.Babel
LOI = LandsOfIllusions

# We need to rename Meteor's email since defining a class with the same name would overwrite it.
EmailMeteor = Email

class LOI.Emails.Email extends LOI.Emails.Email
  @send: (character) ->
    {text, html} = @body character
    sender = @sender()
    characterName = character.avatar.fullName.translate().text

    EmailMeteor.send
      from: "#{sender.name} <#{sender.address}>"
      to: "#{characterName} <#{character.contactEmail}>"
      subject: @subject()
      text: text
      html: html
