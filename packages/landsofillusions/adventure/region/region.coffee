AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Region extends LOI.Adventure.Thing
  @fullName: -> null # Regions don't need to be named.

  @timelineId: -> # Override to set a default timeline for scenes.
  timelineId: -> @constructor.timelineId()

  @scenes: -> [] # Override to provide global scenes.

  @exitLocation: -> throw new AE.NotImplementedException "If the region isn't public, you must specify an exit location."

  @playerHasPermission: ->
    # Override to run the logic that checks if the player is allowed in this region's locations.
    true

  @validateUser: ->
    Meteor.userId()?

  @validatePlayerAccess: ->
    return false unless user = Retronator.user()

    user.hasItem Retronator.Store.Items.CatalogKeys.PixelArtAcademy.PlayerAccess

  @validateAvatarEditor: ->
    return false unless user = Retronator.user()

    user.hasItem Retronator.Store.Items.CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor

  @validateIdeaGardenAccess: ->
    return false unless user = Retronator.user()

    user.hasItem Retronator.Store.Items.CatalogKeys.Retropolis.IdeaGardenAccess

  @validatePatronClubMember: ->
    return false unless user = Retronator.user()

    user.hasItem Retronator.Store.Items.CatalogKeys.Retropolis.PatronClubMember

  constructor: ->
    super

    @_scenes = for sceneClass in @constructor.scenes()
      new sceneClass parent: @

  destroy: ->
    super

    scene.destroy() for scene in @scenes

  scenes: ->
    @_scenes
