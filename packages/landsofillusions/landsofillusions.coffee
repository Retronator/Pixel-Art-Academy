class LandsOfIllusions
  LOI = @

  @debug = false

  @TimelineIds:
    # Default timeline.
    RealLife: 'RealLife'

    # Reliving a memory.
    Memory: 'Memory'

  # Placeholder for the global Adventure instance.
  @adventure = null
  @adventureInitialized = new ReactiveField false

  # Helper to get the default Lands of Illusions palette.
  @palette: ->
    LOI.Assets.Palette.documents.findOne name: LOI.Assets.Palette.defaultPaletteName

  # Access to package's objects.
  @packages = {}

  @initializePackage: (packageObjects) ->
    @0[packageObjects.id] = packageObjects

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
    Retronator.App.addAdminPage '/admin/landsofillusions/memories/actionslog', @constructor.Pages.Admin.Memories.ActionsLog
    Retronator.App.addAdminPage '/admin/landsofillusions/groupphoto', @constructor.Pages.Admin.GroupPhoto
