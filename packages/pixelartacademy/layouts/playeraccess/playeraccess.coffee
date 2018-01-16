AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Layouts.PlayerAccess extends BlazeComponent
  @register 'PixelArtAcademy.Layouts.PlayerAccess'

  @title: ->
    "Pixel Art Academy"

  loading: ->
    Meteor.loggingIn()

  characters: ->
    user = Retronator.Accounts.User.documents.findOne Meteor.userId(),
      fields:
        characters: 1

    user?.characters

  events: ->
    super.concat
      'click .load-character': @onClickLoadCharacter

  onClickLoadCharacter: (event) ->
    # HACK: We save player's exit location since we're immersing the player here into the character.
    # We won't need this when the switch will happen through the usual adventure interface.
    playerTimelineId = new ReactiveField null

    Artificial.Mummification.PersistentStorage.persist
      storageKey: 'LandsOfIllusions.Adventure.currentTimelineId'
      field: playerTimelineId
      tracker: @

    # Save where we're going to immersion from.
    if playerTimelineId() is LOI.TimelineIds.RealLife
      playerLocationId = new ReactiveField null
      Artificial.Mummification.PersistentStorage.persist
        storageKey: 'LandsOfIllusions.Adventure.currentLocationId'
        field: playerLocationId
        tracker: @

      immersionExitLocationId = new ReactiveField null
      Artificial.Mummification.PersistentStorage.persist
        storageKey: 'LandsOfIllusions.Adventure.immersionExitLocationId'
        field: immersionExitLocationId
        tracker: @

      # Save current location to local storage.
      currentLocationId = playerLocationId()
      immersionExitLocationId currentLocationId

    characterId = @currentData()._id
    LOI.switchCharacter characterId
