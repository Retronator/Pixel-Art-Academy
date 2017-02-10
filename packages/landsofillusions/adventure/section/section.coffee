LOI = LandsOfIllusions

class LOI.Adventure.Section
  @scenes: -> throw new AE.NotImplementedException

  active: -> throw new AE.NotImplementedException

  constructor: ->
    @finished = new ReactiveField false
