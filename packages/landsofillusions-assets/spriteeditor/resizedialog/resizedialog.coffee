AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.ResizeDialog extends FM.Dialog
  # keepProportions: boolean whether keep proportions is checked
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.ResizeDialog'
  @register @id()

  onCreated: ->
    super arguments...

    @width = new ReactiveField null
    @height = new ReactiveField null
    @originalProportions = null

    @keepProportions = new ComputedField =>
      @componentData.get('keepProportions') ? true

    # Prefill width and height.
    @autorun (computation) =>
      asset = @interface.getEditorForActiveFile()?.assetData()

      width = asset.bounds?.width
      height = asset.bounds?.height

      @width width
      @height height
      @originalProportions = if width and height then width / height else null

  checkedAttribute: ->
    'checked' if @keepProportions()

  events: ->
    super(arguments...).concat
      'change .width-input': @onChangeWidthInput
      'change .height-input': @onChangeHeightInput
      'change .keepproportions-checkbox': @onChangeKeepProportions
      'click .cancel-button': @onClickCancelButton
      'click .resize-button': @onClickResizeButton

  onClickCancelButton: (event) ->
    @closeDialog()

  onClickResizeButton: (event) ->
    asset = @interface.getEditorForActiveFile()?.assetData()
    LOI.Assets.Sprite.resize asset._id, @width(), @height()
    @closeDialog()

  onChangeWidthInput: (event) ->
    width = _.parseIntOrNull $(event.target).val()

    @width width
    @height Math.round width / @originalProportions if width and @keepProportions()

  onChangeHeightInput: (event) ->
    height = _.parseIntOrNull $(event.target).val()

    @height height
    @width Math.round height * @originalProportions if height and @keepProportions()

  onChangeKeepProportions: (event) ->
    keepProportions = $(event.target).is(':checked')
    @componentData.set 'keepProportions', keepProportions
    return unless keepProportions

    if width = @width()
      @height Math.round width / @originalProportions
