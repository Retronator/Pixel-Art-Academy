RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.User.rename': (name) ->
    check name, String

    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to rename your user account." unless user

    RA.User.documents.update user._id,
      $set:
        'profile.name': name

  'Retronator.Accounts.User.setPrimaryEmail': (emailAddress) ->
    check emailAddress, String

    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to set your primary email." unless user

    emailIndex = _.findIndex user.registered_emails, (email) -> email.address is emailAddress

    throw new AE.ArgumentException "You must provide an existing email address to set it as primary." if emailIndex is -1

    primaryIndex = _.findIndex user.registered_emails, (email) -> email.primary

    return if emailIndex is primaryIndex

    if primaryIndex > -1
      # Unset the previous primary email.
      set = {}
      set["registered_emails.#{primaryIndex}.primary"] = false

      RA.User.documents.update user._id, $set: set

    # Set the new primary email.
    set = {}
    set["registered_emails.#{emailIndex}.primary"] = true

    RA.User.documents.update user._id, $set: set
