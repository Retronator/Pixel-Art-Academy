AB = Artificial.Babel
LOI = LandsOfIllusions

# We need to rename Meteor's email since defining a class with the same name would overwrite it.
EmailMeteor = Email

class LOI.Emails.Email extends LOI.Emails.Email
  @send: (character) ->
    # Make sure the character still has a valid user attached (it could have been retired).
    return unless character.user
    
    {text, html} = @body character
    sender = @sender()
    characterName = character.avatar.fullName.translate().text

    EmailMeteor.send
      from: "#{sender.name} <#{sender.address}>"
      to: "#{characterName} <#{character.contactEmail}>"
      subject: @subject()
      text: text
      html: html
