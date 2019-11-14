class LandsOfIllusions
  LOI = @

  @debug = false

  @TimelineIds:
    # Playing as yourself.
    RealLife: 'RealLife'

    # Lands of Illusions loading program.
    Construct: 'Construct'

    # Playing as your character in the main (non-time-traveling) game world.
    Present: 'Present'

    # Reliving a memory.
    Memory: 'Memory'

  # Placeholder for the global Adventure instance.
  @adventure = null
  @adventureInitialized = new ReactiveField false

  # Character selection and persistence
  @characterIdLocalStorageKey: "LandsOfIllusions.characterId"
  @characterId = new ReactiveField null
  @character = new ReactiveField null

  @agent: ->
    return unless characterId = @characterId()
    LOI.Character.getAgent characterId

  # Helper to get the default Lands of Illusions palette.
  @palette: ->
    LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.defaultPaletteName

  # Method for switching the current character.
  @switchCharacter: (characterId) ->
    # There's nothing to do if the character is already loaded.
    return if @characterId() is characterId

    # Set the character on the object.
    @characterId characterId

  # Access to package's objects.
  @packages = {}

  @initializePackage: (packageObjects) ->
    @packages[packageObjects.id] = packageObjects

  constructor: ->
    Retronator.App.addAdminPage '/admin/landsofillusions', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/landsofillusions/characters', @constructor.Pages.Admin.Characters
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/avatareditor', @constructor.Pages.Admin.Characters.AvatarEditor
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/pre-made-characters', @constructor.Pages.Admin.Characters.PreMadeCharacters
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/approveddesigns', @constructor.Pages.Admin.Characters.ApprovedDesigns
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/outfitstest', @constructor.Pages.Admin.Characters.OutfitsTest
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/characters', @constructor.Pages.Admin.Characters.Characters
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/templates', @constructor.Pages.Admin.Characters.Templates
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/assets', @constructor.Pages.Admin.Characters.Assets
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/animationstest', @constructor.Pages.Admin.Characters.AnimationsTest
    Retronator.App.addAdminPage '/admin/landsofillusions/characters/memberships', @constructor.Pages.Admin.Characters.Memberships
    Retronator.App.addAdminPage '/admin/landsofillusions/memories', @constructor.Pages.Admin.Memories
    Retronator.App.addAdminPage '/admin/landsofillusions/memories/latest', @constructor.Pages.Admin.Memories.Latest
