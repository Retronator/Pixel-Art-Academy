RA = Retronator.Accounts

# Override the user class with extra store functionality.
class RA.User extends RA.User
  @Meta
    name: @id()
    replaceParent: true
    collection: Meteor.users

  @charactersFieldForCurrentUser: @subscription 'charactersFieldForCurrentUser'

  activatedCharacters: ->
    _.filter (@characters), (character) => character.activated
