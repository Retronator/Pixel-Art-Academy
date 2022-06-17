AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor extends LOI.Adventure.Thing
  @styleClass: -> throw new AE.NotImplementedException "Editor must provide a style class name."

  constructor: (@drawing) ->
    super arguments...

    @theme = new ReactiveField null

    @spriteId = new ReactiveField null

    # Allow to manually provide sprite data.
    @manualSpriteData = new ReactiveField null

    @spriteData = new ComputedField =>
      spriteId = @spriteId()
      @manualSpriteData() or LOI.Assets.Sprite.documents.findOne spriteId

    # Allow to manually activate the editor.
    @manuallyActivated = new ReactiveField false

  destroy: ->
    super arguments...

    @spriteData.stop()

  onCreated: ->
    super arguments...

    # Only update spriteId when it has a value, to prevent from destroying the sprite during transitions.
    @autorun (computation) =>
      return unless parameter = AB.Router.getParameter 'parameter3'
      
      # Make sure the parameter is a sprite ID.
      return unless LOI.Assets.Sprite.documents.findOne parameter

      @spriteId parameter

  active: ->
    @manuallyActivated() or AB.Router.getParameter('parameter4') is 'edit'

  focusedMode: ->
    @theme()?.focusedMode?()

  onBackButton: ->
    return unless @manuallyActivated()
    @manuallyActivated false

    # Inform that we've handled the back button.
    true
