AE = Artificial.Everywhere
RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.User.sendVerificationEmail': (emailAddress) ->
    check emailAddress, String

    userId = Meteor.userId()

    throw new AE.UnauthorizedException "You must be logged in to send a verification email." unless userId

    Accounts.sendVerificationEmail userId, emailAddress

  'Retronator.Accounts.User.addEmail': (emailAddress) ->
    check emailAddress, String

    userId = Meteor.userId()

    throw new AE.UnauthorizedException "You must be logged in to add an email." unless userId

    Accounts.addEmail userId, emailAddress

    # Also update registered_emails. We need to fetch user here so it has the updated email fields.
    AccountsEmailsField.updateEmails user: Retronator.user()

  'Retronator.Accounts.User.removeEmail': (emailAddress) ->
    check emailAddress, String

    userId = Meteor.userId()

    throw new AE.UnauthorizedException "You must be logged in to remove an email." unless userId

    Accounts.removeEmail userId, emailAddress

    # Also update registered_emails. We need to fetch user here so it has the updated email fields.
    AccountsEmailsField.updateEmails user: Retronator.user()

  'Retronator.Accounts.User.sendPasswordResetEmail': ->
    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to send the password reset email." unless user

    throw new AE.InvalidOperationException "You must have at least one email to send the reset password to." unless user.contactEmail

    Accounts.sendResetPasswordEmail user._id, user.contactEmail
