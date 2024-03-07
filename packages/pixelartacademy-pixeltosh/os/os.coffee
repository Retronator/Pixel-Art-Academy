AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.OS extends LOI.Component
  @id: -> 'PixelArtAcademy.Pixeltosh.OS'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      startup: AEc.ValueTypes.Trigger

  onCreated: ->
    super arguments...
    
    @programLocation = new PAA.Pixeltosh.Programs
    
    if LOI.adventure
      # Prepare for loading available programs based on gameplay.
      @currentProgramsSituation = new ComputedField =>
        options =
          timelineId: LOI.adventure.currentTimelineId()
          location: @programLocation
  
        return unless options.timelineId and options.location
  
        new LOI.Adventure.Situation options
  
    # We use caches to avoid reconstruction.
    @_programs = {}

    # Instantiates and returns all programs that are available to listen to commands.
    @currentPrograms = new ComputedField =>
      # When running in the adventure interface, get programs from the situation.
      if currentProgramsSituation
        return unless currentProgramsSituation = @currentProgramsSituation()

        programClasses = currentProgramsSituation.things()
        
      else
        # Only load the program referenced by the URL slug.
        programClasses = []

      for programClass in programClasses
        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_programs[programClass.id()] ?= new programClass @

        @_programs[programClass.id()]
        
    @loadedPrograms = new ReactiveField []
    
    @activeProgram = new ComputedField =>
      _.last @loadedPrograms()
    
    @display = @callAncestorWith 'display'
    
    @interface = new @constructor.Interface @
    
    @cursor = new ComputedField =>
      @interface.getView PAA.Pixeltosh.OS.Interface.Cursor
    
  loadProgram: (program) ->
    loadedPrograms = @loadedPrograms()
    loadedPrograms.push program
    Tracker.nonreactive => @loadedPrograms loadedPrograms
    
  unloadProgram: (program) ->
    loadedPrograms = @loadedPrograms()
    loadedPrograms.pull program
    Tracker.nonreactive => @loadedPrograms loadedPrograms

  events: ->
    super(arguments...).concat
      'pointermove .pixelartacademy-pixeltosh-os': @onPointerMovePixeltoshOS
      'pointerleave .pixelartacademy-pixeltosh-os': @onPointerLeavePixeltoshOS
  
  onPointerMovePixeltoshOS: (event) ->
    @cursor().updateCoordinates event
    
  onPointerLeavePixeltoshOS: (event) ->
    @cursor().resetCoordinates()
