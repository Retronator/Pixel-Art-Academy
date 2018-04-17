AB = Artificial.Babel
AC = Artificial.Control
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Items.Sync.Memories extends LOI.Items.Sync.Tab
  @id: -> 'LandsOfIllusions.Items.Sync.Memories'
  @register @id()

  @url: -> 'memories'
  @displayName: -> 'Memories'

  @initialize()

  @previewComponents = {}

  @registerPreviewComponent: (contextId, component) ->
    @previewComponents[contextId] = component

  onCreated: ->
    super

    @limit = new ReactiveField 20
    @currentOffset = new ReactiveField 0

    # Automatically increase the limit.
    @autorun (computation) =>
      currentOffset = @currentOffset()
      limit = @limit()

      # Go 10 beyond the current offset.
      limit += 10 while limit < currentOffset + 10

      @limit limit

    @autorun (computation) =>
      return unless characterId = LOI.characterId()

      # Subscribe to the memories of this character.
      LOI.Memory.forCharacter.subscribe characterId, @limit()

      # Get the document with memory progress.
      LOI.Memory.Progress.forCharacter.subscribe characterId

    @characterImages = {}
    @_characterImagesDependency = new Tracker.Dependency

  onDestroyed: ->
    super

    characterImage.updateAutorun.stop() for characterId, characterImage of @characterImages

  getCharacterImage: (characterId) ->
    # Start rendering this avatar if we haven't yet.
    @characterImages[characterId] ?=
      image: new ReactiveField null
      updateAutorun: Tracker.autorun (computation) =>
        # Render avatar to image.
        character = LOI.Character.getInstance characterId
        renderer = character.avatar.renderer()

        # Wait until character has loaded and renderer is ready.
        return unless character.document()
        return unless renderer.ready()

        canvas = $('<canvas>')[0]
        canvas.width = 16
        canvas.height = 64

        context = canvas.getContext '2d'

        context.setTransform 1, 0, 0, 1, Math.floor(canvas.width / 2), Math.floor(canvas.height / 2)
        context.clearRect 0, 0, canvas.width, canvas.height

        # Draw and pass the root part in options so we can do different rendering paths based on it.
        renderer.drawToContext context,
          rootPart: character.avatar
          lightDirection: => new THREE.Vector3(0, -1, -1).normalize()

        canvas.toBlob (blob) =>
          # Update the image.
          @characterImages[characterId].image URL.createObjectURL blob

    # Return the image.
    @characterImages[characterId].image()

  memories: ->
    skip = Math.max 0, Math.floor @currentOffset() - 5

    memories = LOI.Memory.forCharacter.query(LOI.characterId(), 15, skip).fetch()

    for memory, index in memories
      _id: memory._id
      memory: memory
      index: index + skip

  memoryStyle: ->
    memoryInfo = @currentData()
    index = memoryInfo.index

    offset = @currentOffset()
    depth = (index - offset) * -10
    depth *= 5 if depth > 0
    opacity = _.clamp 1 - (-depth - 20) / 40, 0, 1

    transform: "translateZ(#{depth}rem)"
    zIndex: -index
    opacity: opacity

  endDate: ->
    memory = @currentData()

    memory.endTime.toLocaleString AB.currentLanguage(),
      year: 'numeric'
      month: 'long'
      day: 'numeric'

  updatedClass: ->
    memoryInfo = @currentData()
    memory = memoryInfo.memory
    
    return unless progress = LOI.Memory.Progress.documents.findOne 'character._id': LOI.characterId()
    
    observedMemory = _.find progress.observedMemories, (observedMemory) => observedMemory.memory._id is memory._id
      
    # Memory has new actions unless the last action (memory's end time) 
    # is at the time the character last observed this memory (they have seen it through).
    'updated' unless memory.endTime.getTime() <= observedMemory?.time.getTime()

  events: ->
    super.concat
      'wheel': @onMouseWheel
      'click .memory .preview': @onClickMemoryPreview

  onMouseWheel: (event) ->
    event.preventDefault()

    offset = @currentOffset()
    offset -= event.originalEvent.deltaY * 0.01

    limit = @limit()
    @currentOffset _.clamp offset, -0.5, limit

    # Round to integer after the user pauses scrolling.
    @_debouncedRound ?= _.debounce =>
      @currentOffset Math.ceil @currentOffset() - 0.1
    ,
      500

    @_debouncedRound()

  onClickMemoryPreview: (event) ->
    memory = @currentData()

    # Remember the offset used.
    lastOffset = @currentOffset()

    LOI.adventure.enterMemory memory
    @sync.close()

    # Start listening for the tab command.
    onKeyDownHandler = (event) =>
      keyCode = event.which
      return unless keyCode is AC.Keys.tab

      LOI.adventure.exitMemory()

    $(document).on 'keydown', onKeyDownHandler

    # Start waiting for the memory to be exited.
    Tracker.autorun (computation) =>
      return if LOI.adventure.currentMemoryId()

      # Wait also until sync is created again.
      return unless sync = LOI.adventure.getCurrentThing LOI.Items.Sync
      return unless sync.isCreated()
      computation.stop()

      # Stop listening for the tab command.
      $(document).off 'keydown', onKeyDownHandler

      # Re-open sync to show the memory we exited.
      sync.currentTab sync.memoriesTab
      sync.open()

      # We need a nonreactive block to run an autorun inside a stopped autorun.
      Tracker.nonreactive =>
        Tracker.autorun (computation) =>
          return unless sync.memoriesTab.isCreated()
          computation.stop()

          sync.memoriesTab.currentOffset lastOffset

    # Update progress on this memory to indicate it was observed.
    # TODO: LOI.Memory.Progress.updateProgress LOI.characterId(), memory._id, memory.endTime

  class @Preview extends AM.Component
    @register 'LandsOfIllusions.Items.Sync.Memories.Preview'

    onCreated: ->
      super

      memory = @data()

      context = LOI.Memory.Context.createContext memory
      previewComponent = LOI.Items.Sync.Memories.previewComponents[context.id()]

      @preview = new previewComponent()

    renderPreview: ->
      @preview.renderComponent @
