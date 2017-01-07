AT = Artificial.Telepathy

# Set to immediately send a verification email on registration.
Accounts.config
  sendVerificationEmail: true

Accounts.emailTemplates.siteName = "Retronator"
Accounts.emailTemplates.from = "Retronator <hi@retronator.com>"

Meteor.startup ->
  # TODO: Get translatable email templates from the DB.
  Accounts.emailTemplates.verifyEmail.subject = (user) ->
    "Verify your Pixel Art Academy account email"

  Accounts.emailTemplates.verifyEmail.text = (user, url) -> createVerificationEmail(user, url).text
  Accounts.emailTemplates.verifyEmail.html = (user, url) -> createVerificationEmail(user, url).html

createVerificationEmail = (user, url) ->
  email = new AT.EmailComposer

  if user.profile?.name
    email.addParagraph "Hey #{user.profile.name},"

  else
    email.addParagraph "Hey,"
  
  email.addParagraph "To verify this email in your Pixel Art Academy account,
                        click on the link below:"

  email.addLinkParagraph url

  email.addParagraph "Let me know if you have any questions. Welcome to the Retronator family!"

  email.addParagraph "Cheers,\n
                        Matej 'Retro' Jan // Retronator"

  email
