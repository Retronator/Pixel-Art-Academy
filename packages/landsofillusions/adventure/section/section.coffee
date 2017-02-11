LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> "" # Sections don't need to be named.

  active: -> throw new AE.NotImplementedException

  constructor: ->
    super

    @finished = new ReactiveField false
