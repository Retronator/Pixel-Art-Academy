AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends AM.Component
  @Locations = {}

  @setUrl: (@url) ->
    # Store location class into locations broken down by its url.
    _.nestedProperty LOI.Adventure.Location.Locations, @url.replace('/', '.'), @

  template: ->
    'LandsOfIllusions.Adventure.Location'
    
  illustrationHeight: ->
    0

  constructor: ->
    super

    @director = new LOI.Adventure.Director @
    @actors = new ReactiveField []

  addActor: (actor) ->
    actor.director @director
    @actors @actors().concat actor
