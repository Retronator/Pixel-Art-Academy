AE = Artificial.Everywhere
RA = Retronator.Accounts
LOI = LandsOfIllusions
E1 = PixelArtAcademy.Season1.Episode1

Meteor.methods
  'PixelArtAcademy.Season1.Episode1.Pages.Admin.Admissions.processApplied': ->
    RA.authorizeAdmin()

    console.log "Processing applied characters."

    # Find all character states that have applied, but haven't been accepted yet.
    gameStates = LOI.GameState.documents.fetch
      'readOnlyState.things.PixelArtAcademy.Season1.Episode1.Chapter1.application.applied': true
      'readOnlyState.things.PixelArtAcademy.Season1.Episode1.Chapter1.application.accepted': $ne: true

    for gameState in gameStates
      character = LOI.Character.documents.findOne gameState.character._id
      unless character?.user
        console.log "Character has been archived (missing user).", character.debugName, character._id
        continue

      user = RA.User.documents.findOne character.user._id
      unless user
        console.log "Character's user could not be found.", character.debugName, character._id
        continue

      # Accept applications that meet chapter requirement.
      unless user.hasItem E1.Chapter1.accessRequirement()
        console.log "Character does not meet the requirements.", character.debugName, character._id
        continue

      event = _.find gameState.events, (event) -> event.type is "#{E1.Chapter1.id()}.Events.ApplicationAccepted"

      if event
        console.log "Character already has acceptance event scheduled.", character.debugName, character._id
        continue

      console.log "Accepting character", character.debugName, character._id
      E1.Chapter1.acceptCharacter character._id

    console.log "Processed #{gameStates.length} characters."
