AB = Artificial.Babel
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.Sync.Memories extends PAA.Items.Sync.Tab
  @id: -> 'PixelArtAcademy.Items.Sync.Memories'
  @register @id()

  @url: -> 'memories'
  @displayName: -> 'Memories'

  @initialize()

  onCreated: ->
    super

    @limit = new ReactiveField 20
    @currentOffset = new ReactiveField 0

    @autorun (computation) =>
      if @currentOffset() > @limit() - 10
        Tracker.nonreactive =>
          @limit @limit() + 10

    @autorun (computation) =>
      LOI.Memory.forCharacter.subscribe LOI.characterId(), @limit()

  memories: ->
    skip = Math.max 0, Math.floor @currentOffset() - 5

    memories = LOI.Memory.documents.find(
      'actions.character._id': LOI.characterId()
    ,
      limit: 15
      skip: skip
      sort:
        endTime: -1
    ).fetch()

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

  events: ->
    super.concat
      'wheel': @onMouseWheel

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
