class LandsOfIllusions
  LOI = @

  # Create the user helper on the LOI object for convenience.
  @user: ->
    @Accounts.User.documents.findOne Meteor.userId()

  # Create the characterId and character helpers.
  @characterId: ->
    @Accounts._characterId()

  @character: ->
    @Accounts.Character.documents.findOne @characterId()

  # Helper to get the default Lands of Illusions palette.
  @palette: ->
    LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.defaultPaletteName

  @isRunningLocally: ->
    not Meteor.settings.public?.landsOfIllusionsUrl

Meteor.methods
  # Convenience method for re-running auto-generated fields and syncing of references.
  updateAllDocuments: ->
    LOI.Authorize.admin()
    Document.updateAll()

if Meteor.isClient
  Blaze.registerHelper 'isRunningLocally', ->
    LOI.isRunningLocally()
