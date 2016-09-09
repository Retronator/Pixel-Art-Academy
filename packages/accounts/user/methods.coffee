RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.User.rename': (name) ->
    check name, String

    RA.User.documents.update Meteor.user(),
      $set:
        'profile.name': name

  'Retronator.Accounts.User.setSupporterName': (name) ->
    check name, String

    RA.User.documents.update Meteor.user(),
      $set:
        'profile.supporterName': name

  'Retronator.Accounts.User.setShowSupporterName': (value) ->
    check value, Boolean

    RA.User.documents.update Meteor.user(),
      $set:
        'profile.showSupporterName': value

  'Retronator.Accounts.User.sendVerificationEmail': (emailAddress) ->
    check emailAddress, String

    return unless Meteor.isServer
    return unless Meteor.userId()

    Accounts.sendVerificationEmail Meteor.userId(), emailAddress

  'Retronator.Accounts.User.addEmail': (emailAddress) ->
    check emailAddress, String

    return unless Meteor.isServer
    return unless Meteor.userId()

    Accounts.addEmail Meteor.userId(), emailAddress

    # Also update registered_emails.
    AccountsEmailsField.updateEmails user: Meteor.user()

  'Retronator.Accounts.User.generateItemsArrayForCurrentUser': ->
    Retronator.user().generateItemsArray()
