RA = Retronator.Accounts

# Override the user class with extra Adventure Mode functionality.
class RA.User extends RA.User
  @Meta
    name: @id()
    replaceParent: true
    collection: Meteor.users

  @charactersFieldForCurrentUser: @subscription 'charactersFieldForCurrentUser'

  activatedCharacters: ->
    _.filter (@characters), (character) => character.activated

  playableCharacters: ->
    # Playable characters must have been activated and their design hasn't been revoked.
    # If a character is not playable, you can't switch to it (it will be automatically unloaded).
    _.filter (@characters), (character) => character.activated and character.designApproved
