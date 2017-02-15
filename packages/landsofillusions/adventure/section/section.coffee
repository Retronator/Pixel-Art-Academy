AE = Artificial.Everywhere
LOI = LandsOfIllusions

class LOI.Adventure.Section extends LOI.Adventure.Thing
  @scenes: -> throw new AE.NotImplementedException

  @fullName: -> "" # Sections don't need to be named.

  @finished: -> false # Override to set goal state conditions.
  finished: -> @constructor.finished()

  constructor: ->
    super

    # React to section becoming active.
    @autorun (computation) =>
      active = @active()
      return unless active?

      if active and @_wasActive is false
        @onStart()

      @_wasActive = active

  active: ->
    # Override and add additional logic to create prerequisites for the section being started.
    finished = @finished()

    # Finished can return undefined, which means it is not ready to determine its state.
    return unless finished?

    # By default the section is active until it is finished.
    not finished

  onStart: -> # Override to provide any initialization logic when the section begins.
