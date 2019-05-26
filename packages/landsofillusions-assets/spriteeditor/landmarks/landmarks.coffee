AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.SpriteEditor.Landmarks extends FM.View
  @id: -> 'LandsOfIllusions.Assets.SpriteEditor.Landmarks'
  @register @id()

  onCreated: ->
    super arguments...

    @landmarksHelper = new ComputedField =>
      @interface.getHelperForActiveFile LOI.Assets.SpriteEditor.Helpers.Landmarks

    @landmarks = new ComputedField =>
      @landmarksHelper()?.landmarks()

  # Events

  events: ->
    super(arguments...).concat
      'change .number-input': @onChangeNumber
      'change .name-input, change .coordinate-input': @onChangeLandmark
      'click .add-landmark-button': @onClickAddLandmarkButton

  onChangeNumber: (event) ->
    landmark = @currentData()

    number = parseInt $(event.target).val()

    # HACK: Replace the number back since it won't update by itself (probably since it's the edited input).
    $(event.target).val landmark.number

    sprite = @landmarksHelper().sprite()

    if _.isNaN number
      LOI.Assets.VisualAsset.removeLandmark sprite.constructor.className, sprite._id, landmark.index

    else
      newIndex = number - 1
      LOI.Assets.VisualAsset.reorderLandmark sprite.constructor.className, sprite._id, landmark.index, newIndex

  onChangeLandmark: (event) ->
    $landmark = $(event.target).closest('.landmark')

    index = @currentData().index

    landmark =
      # We null the name if it's an empty string
      name: $landmark.find('.name-input').val() or null
      
    for property in ['x', 'y', 'z']
      landmark[property] = _.parseFloatOrNull $landmark.find(".coordinate-#{property} .coordinate-input").val()

    sprite = @landmarksHelper().sprite()
    LOI.Assets.VisualAsset.updateLandmark sprite.constructor.className, sprite._id, index, landmark

  onClickAddLandmarkButton: (event) ->
    sprite = @landmarksHelper().sprite()
    index = sprite.landmarks?.length or 0
    LOI.Assets.VisualAsset.updateLandmark sprite.constructor.className, sprite._id, index, {}
