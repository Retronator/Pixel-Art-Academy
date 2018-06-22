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
    # At least one Tools challenge needs to be completed using the editor.

  canDownloadAndUpload: ->
    # At least one Tools challenge needs to be completed using the upload.
    
  noActions: ->
    not (@canEdit() or @canDownloadAndUpload())

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    @parent.editAsset()
