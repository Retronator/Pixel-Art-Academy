AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.Publication.Article.Figure extends AM.Quill.BlotComponent
  @id: -> 'PixelArtAcademy.Publication.Article.Figure'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot
    name: 'publication-figure'
    tag: 'figure'
    class: 'pixelartacademy-publication-article-figure'

  onCreated: ->
    super arguments...

    @preventUpdatesCount = new ReactiveField 0

    @elementRows = new ComputedField =>
      figure = @value()

      elementRows = []
      processedElementsCount = 0

      createElement = (elementIndex) =>
        _.extend
          index: elementIndex
        ,
          figure.elements[elementIndex]

      for elementsPerRow in figure.layout
        currentRowOfElements = []
        elementRows.push elements: currentRowOfElements

        for elementIndexInRow in [0...elementsPerRow]
          element = createElement processedElementsCount
          currentRowOfElements.push element
          processedElementsCount++

      # Check if layout didn't account for all elements.
      if processedElementsCount < figure.elements.length
        # Add any remaining elements.
        for elementIndex in [processedElementsCount...figure.elements.length]
          elementRows.push
            elements: [
              createElement processedElementsCount
            ]

      elementRows

  preventUpdates: ->
    # Cache the current figure so we can apply updates to it.
    preventUpdatesCount = @preventUpdatesCount()
    @_updatedFigure = _.cloneDeep @value() unless preventUpdatesCount

    Tracker.nonreactive => @preventUpdatesCount preventUpdatesCount + 1

  allowUpdates: ->
    preventUpdatesCount = @preventUpdatesCount() - 1
    Tracker.nonreactive => @preventUpdatesCount preventUpdatesCount
    return if preventUpdatesCount

    # No one is preventing updates anymore, so store the final updated figure.
    @setFigure @_updatedFigure

  getFigure: ->
    if @preventUpdatesCount()
      @_updatedFigure

    else
      @value()

  setFigure: (figure) ->
    if @preventUpdatesCount()
      @_updatedFigure = figure

    else
      @value figure

  updateElement: (index, value) ->
    figure = @getFigure()
    element = figure.elements[index]
    elementType = _.keys(element)[0]
    element[elementType] = value
    @setFigure figure

  contentUpdated: ->
    @quillComponent()?.contentUpdated?()

  canEditElements: ->
    not (@readOnly() or @preventUpdatesCount())

  canMoveElementUp: ->
    element = @currentData()
    element.index

  canMoveElementDown: ->
    element = @currentData()
    figure = @getFigure()
    element.index < figure.elements.length - 1

  events: ->
    super(arguments...).concat
      'click .add-element-button': @onClickAddElementButton
      'click .move-element-up-button': @onClickMoveElementUpButton
      'click .move-element-down-button': @onClickMoveElementDownButton
      'click .remove-element-button': @onClickRemoveElementButton
      'paste .caption': @onPasteCaption

  onPasteCaption: (event) ->
    # Don't allow the Quill clipboard to hijack paste into the figure caption.
    event.stopPropagation()

  onClickAddElementButton: (event) ->
    $fileInput = $('<input type="file" multiple/>')

    $fileInput.on 'change', (event) =>
      return unless files = $fileInput[0]?.files

      # Insert a new image to the figure.
      figure = @getFigure()
      figure.elements.push image: {file} for file in files
      figure.layout.push files.length
      @setFigure figure

    $fileInput.click()

  onClickMoveElementUpButton: (event) ->
    elementData = @currentData()
    figure = @getFigure()

    [element] = figure.elements.splice elementData.index, 1
    figure.elements.splice elementData.index - 1, 0, element

    @setFigure figure

  onClickMoveElementDownButton: (event) ->
    elementData = @currentData()
    figure = @getFigure()

    [element] = figure.elements.splice elementData.index, 1
    figure.elements.splice elementData.index + 1, 0, element

    @setFigure figure

  onClickRemoveElementButton: (event) ->
    element = @currentData()

    figure = @getFigure()
    figure.elements.splice element.index, 1

    # Update layout.
    elementsToSkip = element.index
    rowIndex = 0

    # Find row where this element appeared.
    while elementsToSkip > 0
      elementsPerRow = figure.layout[rowIndex]
      elementsToSkip -= elementsPerRow
      break if elementsToSkip < 0
      rowIndex++

    # See if there were multiple items in that row.
    if figure.layout[rowIndex] > 1
      figure.layout[rowIndex]--

    else
      figure.layout.splice rowIndex, 1

    @setFigure figure

  class @Layout extends AM.DataInputComponent
    @register 'PixelArtAcademy.Publication.Article.Figure.Layout'

    constructor: ->
      super arguments...

      @realtime = false

    onCreated: ->
      super arguments...

      @figureComponent = @ancestorComponentOfType PAA.Publication.Article.Figure

    load: ->
      figure = @figureComponent.getFigure()
      layoutText = ""
      layoutText += elementsPerRow for elementsPerRow in figure.layout
      layoutText

    save: (layoutText) ->
      figure = @figureComponent.value()

      figure.layout = for numberText in layoutText
        parseInt numberText

      @figureComponent.setFigure figure

  class @Caption extends AM.DataInputComponent
    @register 'PixelArtAcademy.Publication.Article.Figure.Caption'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.TextArea
      @realtime = false
      @autoResizeTextarea = true

    onCreated: ->
      super arguments...

      @figureComponent = @ancestorComponentOfType PAA.Publication.Article.Figure

    load: ->
      figure = @figureComponent.getFigure()
      figure.caption

    save: (value) ->
      figure = @figureComponent.value()
      figure.caption = value
      @figureComponent.setFigure figure
