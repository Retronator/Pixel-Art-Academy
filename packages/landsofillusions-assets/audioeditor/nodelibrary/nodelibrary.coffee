AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.NodeLibrary extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.NodeLibrary'
  @register @id()

  constructor: (@audioEditor) ->
    super

  onCreated: ->
    super

    @nodeClasses = LOI.Assets.Engine.Audio.Node.getClasses()

    @searchTerm = new ReactiveField ''

    @displayedNodeClasses = new ComputedField =>
      if searchTerm = _.toLower @searchTerm()
        displayedNodeClasses = _.filter @nodeClasses, (nodeClass) => _.toLower(nodeClass.nodeName()).indexOf(searchTerm) > -1

      else
        displayedNodeClasses = @nodeClasses

      displayedNodeClasses = _.sortBy displayedNodeClasses, (nodeClass) => nodeClass.nodeName()

      for nodeClass in displayedNodeClasses
        _id: nodeClass.type()
        nodeClass: nodeClass

  events: ->
    super.concat
      'mousedown .landsofillusions-assets-audioeditor-node': @onMouseDownNode
      'input .search .input': @onInputSearchInput
      'click .search .clear-input-button': @onSearchClickClearInputButton

  onMouseDownNode: (event) ->
    nodeClassInfo = @currentData()

    # Prevent browser select/dragging behavior
    event.preventDefault()

    # Add this node to the canvas.
    @audioEditor.addNode
      nodeClass: nodeClassInfo.nodeClass
      element: event.currentTarget
      event: event

  onInputSearchInput: (event) ->
    @searchTerm $(event.target).val()

  onSearchClickClearInputButton: (event) ->
    @searchTerm ''
