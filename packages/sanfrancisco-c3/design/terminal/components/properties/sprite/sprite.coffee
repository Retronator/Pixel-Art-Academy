AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Sprite extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Sprite'

  onCreated: ->
    super

    @property = @data()

    @spriteId = @property.options.dataLocation.child 'spriteId'

    @spriteList = new LOI.Assets.Components.AssetsList
      documentClass: LOI.Assets.Sprite
      getAssetId: @spriteId
      setAssetId: (spriteId) =>
        # Set the new sprite.
        @spriteId spriteId

        # Close the selection UI.
        @showSpriteList false

    @showSpriteList = new ReactiveField false

    @spriteImage = new LOI.Assets.Components.SpriteImage
      spriteId: @spriteId

  showSpritePreview: ->
    @spriteId()

  events: ->
    super.concat
      'click .choose-sprite-button': @onClickChooseSpriteButton

  onClickChooseSpriteButton: (event) ->
    @showSpriteList not @showSpriteList()
