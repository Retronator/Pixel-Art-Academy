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
    not (PAA.PixelBoy.Apps.Drawing.state('editorId')) # TODO: or PAA.PixelBoy.Apps.Drawing.state('externalSoftware'))

  needsToolsChallenge: ->
    true

  canEdit: ->
    # Editor needs to be selected.
    return unless PAA.PixelBoy.Apps.Drawing.state('editorId')

    # TODO: At least one Tools challenge needs to be completed using the editor.
    true

  canDownloadAndUpload: ->
    # TODO: At least one Tools challenge needs to be completed using the upload.
    false
    
  noActions: ->
    not (@canEdit() or @canDownloadAndUpload())

  events: ->
    super.concat
      'click .edit-button': @onClickEditButton

  onClickEditButton: (event) ->
    @parent.editAsset()
