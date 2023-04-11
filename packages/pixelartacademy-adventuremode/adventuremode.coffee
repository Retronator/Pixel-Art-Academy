LOI = LandsOfIllusions

class PixelArtAcademy.AdventureMode
  constructor: ->
    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage 'pixelart.academy/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', @constructor.Adventure

  @TimelineIds:
    # Dream sequence from the intro episode.
    DareToDream: 'DareToDream'

    # Lands of Illusions loading program.
    Construct: 'Construct'

    # Playing as your character in the main (non-time-traveling) game world.
    Present: 'Present'

# Character selection and persistence
LOI.characterIdLocalStorageKey = "LandsOfIllusions.characterId"
LOI.characterId = new ReactiveField null
LOI.character = new ReactiveField null

LOI.agent = ->
  return unless characterId = @characterId()
  LOI.Character.getAgent characterId

# Method for switching the current character.
LOI.switchCharacter = (characterId) ->
  # There's nothing to do if the character is already loaded.
  return if @characterId() is characterId
  
  # Set the character on the object.
  @characterId characterId
  
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_pixelartacademy-adventuremode'
    assets: Assets

  # Export assets in the pixelartacademy folder.
  LOI.Assets.addToExport 'pixelartacademy'
