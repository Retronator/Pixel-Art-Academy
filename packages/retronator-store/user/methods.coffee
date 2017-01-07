RA = Retronator.Accounts

Meteor.methods
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

  'Retronator.Accounts.User.generateItemsArrayForCurrentUser': ->
    Retronator.user().generateItemsArray()
