LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction.Photos extends HQ.Store.Table.Interaction
  @id: -> 'Retronator.HQ.Store.Table.Interaction.Photos'

  @register @id()
  template: -> @constructor.id()

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor2/store/table/interaction/photos/photos.script'

  @initialize()

  constructor: (@photos) ->
    super

  addPhoto: (photo) ->
    @photos.push photo

  start: (@startOptions) ->
    listener = @listeners[0]

    if @startOptions.justActivate
      listener.startScript label: 'Activate'
      
    else
      listener.startScript label: if @photos.length is 1 then 'LookAtPhoto' else 'LookAtPhotos'

  provideCallbacks: ->
    LookAtPhotos: (complete) =>
      @interact => complete()
