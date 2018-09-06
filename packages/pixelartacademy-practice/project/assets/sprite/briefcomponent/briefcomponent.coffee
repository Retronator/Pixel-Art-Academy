AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Asset.Sprite.BriefComponent extends AM.Component
  @register 'PixelArtAcademy.Practice.Project.Asset.Sprite.BriefComponent'

  constructor: (@sprite) ->
    super
    
  onCreated: ->
    super
    
    @parent = @ancestorComponentWith 'editAsset'

  needsSettingsSelection: ->
    not (PAA.PixelBoy.Apps.Drawing.state('editorId') or PAA.PixelBoy.Apps.Drawing.state('externalSoftware'))

  needsToolsChallenge: ->
    true

  canEdit: ->
    # Editor needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId')

    PAA.Practice.Project.Asset.Sprite.state 'canEdit'

  canUpload: ->
    # External software needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('externalSoftware')

    PAA.Practice.Project.Asset.Sprite.state 'canUpload'
    
  noActions: ->
    not (@canEdit() or @canUpload())

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton
      'click .assets-button': @onClickAssetsButton

  onClickEditButton: (event) ->
    @parent.editAsset()

  onClickAssetsButton: (event) ->
    @parent.showSecondPage()
