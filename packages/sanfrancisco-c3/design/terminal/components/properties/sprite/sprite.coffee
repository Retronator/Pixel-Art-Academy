AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.Sprite extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.Sprite'

  onCreated: ->
    super

    @property = @data()

    @spriteId = @property.options.dataLocation.child 'spriteId'

    @spriteIdInput = new @constructor.IDInput dataLocation: @spriteId

  events: ->
    super.concat
      'click .new-sprite-button': @onClickNewSpriteButton

  onClickNewSpriteButton: (event) ->
    LOI.Assets.Sprite.insert (error, spriteId) =>
      if error
        console.error error
        return

      # Set the new sprite as the sprite of this property.
      @spriteId spriteId

  # Components

  class @IDInput extends AM.DataInputComponent
    constructor: (@options) ->
      super
      
      @realtime = false
      @autoSelect = true

    load: ->
      @options.dataLocation()

    save: (value) ->
      @options.dataLocation value
