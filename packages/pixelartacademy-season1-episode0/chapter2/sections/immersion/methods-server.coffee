C2 = PixelArtAcademy.Season1.Episode0.Chapter2
HQ = Retronator.HQ
AT = Artificial.Telepathy

methods = {}
methods[C2.Immersion.userProblemMessage] =  ->
  user = Retronator.user()
  
  # First send an email to myself.
  adminEmail = new AT.EmailComposer
  adminEmail.addParagraph "User is having trouble logging into Lands of Illusions."
  adminEmail.addParagraph "ID: #{user._id}"
  adminEmail.end()

  Email.send
    from: "hi@retronator.com"
    to: "hi@retronator.com"
    subject: "User help request"
    text: adminEmail.text
    html: adminEmail.html
  
  # Now send an email to the customer, if possible.
  unless user.contactEmail
    # We don't have user's email, so we can't send them the email (for example, if they logged in with Twitter only).
    # Exception is not thrown so that the method completes, but we can't continue with emailing.
    console.warning "Email was not sent for user who needed help logging into Lands of Illusions.", user
    return

  email = new AT.EmailComposer

  email.addParagraph "Hey #{user.displayName},"

  email.addParagraph "Sorry for having trouble with signing in to Lands of Illusions."

  email.addParagraph "I will look into it at the earliest convenience."

  email.addParagraph "I really do apologize. It's my first priority to make things work for supporters, but since it's mainly just me working on the system, things sometimes go wrong."

  email.addParagraph "I will email back as soon as I've investigated what the problem could be."

  email.addParagraph "Best,\n
                      Retro"

  email.end()

  Email.send
    from: "hi@retronator.com"
    to: user.contactEmail
    subject: "Lands of Illusions problem signing in"
    text: email.text
    html: email.html

Meteor.methods methods
