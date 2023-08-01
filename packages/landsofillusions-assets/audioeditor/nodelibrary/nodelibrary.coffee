AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
AEc = Artificial.Echo
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.NodeLibrary extends FM.View
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.NodeLibrary'
  @register @id()

  onCreated: ->
    super arguments...

    @nodeClasses = AEc.Node.getClasses()

    @searchTerm = new ReactiveField ''

    @displayedNodeClasses = new ComputedField =>
      if searchTerm = _.toLower @searchTerm()
        displayedNodeClasses = _.filter @nodeClasses, (nodeClass) => _.toLower(nodeClass.displayName()).indexOf(searchTerm) > -1

      else
        displayedNodeClasses = @nodeClasses

      displayedNodeClasses = _.sortBy displayedNodeClasses, (nodeClass) => nodeClass.displayName()

      for nodeClass in displayedNodeClasses
        _id: nodeClass.type()
        nodeClass: nodeClass
        nodeType: nodeClass.type()

  events: ->
    super(arguments...).concat
      'mousedown .landsofillusions-assets-audioeditor-node': @onMouseDownNode
      'input .search .input': @onInputSearchInput
      'click .search .clear-input-button': @onSearchClickClearInputButton

  onMouseDownNode: (event) ->
    nodeClassInfo = @currentData()

    # Prevent browser select/dragging behavior
    event.preventDefault()

    # Add this node to the canvas.
    loader = @interface.getLoaderForActiveFile()
    loader.addNode
      nodeClass: nodeClassInfo.nodeClass
      element: event.currentTarget
      event: event

  onInputSearchInput: (event) ->
    @searchTerm $(event.target).val()

  onSearchClickClearInputButton: (event) ->
    @searchTerm ''
