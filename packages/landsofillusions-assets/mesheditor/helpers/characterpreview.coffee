FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.MeshEditor.Helpers.CharacterPreview extends FM.Helper
  # enabled: boolean whether the scene should include a human
  # characterId: which character to add to the scene
  # position: vector where the root of the character will be
  #   x, y, z
  # direction: vector where the character is facing
  #   x, y, z
  @id: -> 'LandsOfIllusions.Assets.MeshEditor.Helpers.CharacterPreview'
  @initialize()

  constructor: ->
    super arguments...

    @sceneHelper = new ComputedField =>
      @interface.getHelperForFile LOI.Assets.MeshEditor.Helpers.Scene, @fileId

    @_character = null

    @characterDocument = new ComputedField =>
      return unless characterId = @data.get 'characterId'

      LOI.Character.forId.subscribe characterId
      LOI.Character.documents.findOne characterId

    # Create and destroy avatar's render object.
    @avatar = new ReactiveField null
    @renderObject = new ReactiveField null

    @autorun (computation) =>
      return unless sceneHelper = @sceneHelper()
      scene = sceneHelper.scene()
      enabled = @enabled()
      avatar = @avatar()

      if avatar and not enabled
        # Remove the character.
        Tracker.nonreactive =>
          renderObject = @renderObject()
          scene.remove renderObject
          @renderObject null

          avatar.destroy()
          @avatar null

        sceneHelper.scene.updated()

      else if not avatar and enabled
        # Create and add the character.
        Tracker.nonreactive =>
          avatar = new LOI.Character.Avatar => @characterDocument()
          renderObject = avatar.getRenderObject()
          scene.add renderObject

          @renderObject renderObject
          @avatar avatar

        sceneHelper.scene.updated()

    # Position the render object.
    @autorun (computation) =>
      return unless sceneHelper = @sceneHelper()
      return unless renderObject = @renderObject()

      position = @data.get 'position'
      direction = @data.get 'direction'

      renderObject.position.copy position if position?
      renderObject.faceDirection direction if direction?

      sceneHelper.scene.updated()

  enabled: -> @data.get 'enabled'
  setEnabled: (value) ->
    @data.set 'enabled', value

    unless @data.get 'characterId'
      @interface.displayDialog
        contentComponentId: LOI.Assets.MeshEditor.CharacterSelectionDialog.id()

  setCharacterId: (value) -> @data.set 'characterId', value
  setPosition: (value) -> @data.set 'position', value
  setDirection: (value) -> @data.set 'direction', value

  toggle: -> @setEnabled not @value()?.enabled
