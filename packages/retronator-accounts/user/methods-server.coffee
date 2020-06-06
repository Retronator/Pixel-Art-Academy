AE = Artificial.Everywhere
RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.User.sendVerificationEmail': (emailAddress) ->
    check emailAddress, String

    user = Meteor.user()

    throw new AE.UnauthorizedException "You must be logged in to send a verification email." unless user

    # Make sure the email address is added to the user.
    email = _.find user.emails, (email) -> email.address is emailAddress

    unless email
      # See if the email is instead in registered_emails and got added through a service.
      email = _.find user.registered_emails, (email) -> email.address is emailAddress

      if email
        # Let's add it to the emails collection.
        Accounts.addEmail user._id, emailAddress

      throw new AE.ArgumentException "The provided email address is not linked to your account." unless email

    Accounts.sendVerificationEmail user._id, emailAddress

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

    throw new AE.InvalidOperationException "You must have a contact email set to send the reset password to." unless user.contactEmail

    # Make sure the contact email address is added directly to the user (and not via registered_emails).
    email = _.find user.emails, (email) -> email.address is user.contactEmail

    unless email
      # Let's add it to the emails collection.
      Accounts.addEmail user._id, user.contactEmail

    Accounts.sendResetPasswordEmail user._id, user.contactEmail

RA.User.unlinkService.method (serviceName) ->
  check serviceName, String

  serviceName = _.toLower serviceName

  check serviceName, Match.Where (value) ->
    value in ['facebook', 'twitter', 'google', 'patreon']

  user = Retronator.requireUser()
  throw new AE.UnauthorizedException "You do not have a #{serviceName} account linked." unless user.services?[serviceName]

  Accounts.unlinkService user._id, serviceName
