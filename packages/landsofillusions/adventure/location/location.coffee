AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Location extends AM.Component
  @register 'LandsOfIllusions.Adventure.Location'

  # The unique name that is used to identify the location in code and in urls
  keyName: -> throw new Meteor.Error 'unimplemented', "You must specify locations's key name."

  # The name that appears as the location's description.
  displayName: -> throw new Meteor.Error 'unimplemented', "You must specify location's display name."

  constructor: ->
    super

    @director = new LOI.Adventure.Director @
    @actors = new ReactiveField []

  addActor: (actor) ->
    actor.director = @director
    @actors @actors().concat actor
