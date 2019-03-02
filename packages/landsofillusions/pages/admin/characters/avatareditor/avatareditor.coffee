AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.AvatarEditor extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters.AvatarEditor'
  
  onCreated: ->
    super arguments...

    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 640
      minScale: LOI.settings.graphics.minimumScale.value
      maxScale: LOI.settings.graphics.maximumScale.value
      minAspectRatio: 1 / 2
      maxAspectRatio: 2

    # Subscribe to all avatar sprites.
    types = LOI.Character.Part.allAvatarPartTypeIds()
    LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.subscribe types

    # Create a terminal that uses sprites from the database to allow live editing
    @terminal = new SanFrancisco.C3.Design.Terminal useDatabaseSprites: true
