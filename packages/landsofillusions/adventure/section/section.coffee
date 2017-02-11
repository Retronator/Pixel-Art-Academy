AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> "" # Sections don't need to be named.

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

  active: ->
    # By default the section is active until it is finished. Override and add
    # additional logic to create prerequisites for the section being started.
    not @finished()
