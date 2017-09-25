RA = Retronator.Accounts

Meteor.methods
  'Retronator.Accounts.User.setSupporterName': (name) ->
    check name, String

    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to set your supporter name." unless user

    RA.User.documents.update user._id,
      $set:
        'profile.supporterName': name

  'Retronator.Accounts.User.setShowSupporterName': (value) ->
    check value, Boolean

    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to show or hide your supporter name." unless user

    RA.User.documents.update user._id,
      $set:
        'profile.showSupporterName': value

  'Retronator.Accounts.User.setSupporterMessage': (name) ->
    check name, String

    user = Retronator.user()

    throw new AE.UnauthorizedException "You must be logged in to set your supporter message." unless user

    RA.User.documents.update user._id,
      $set:
        'profile.supporterMessage': name

  'Retronator.Accounts.User.generateItemsArrayForCurrentUser': ->
    Retronator.user().generateItemsArray()
