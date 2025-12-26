import {ComputedField} from "meteor/peerlibrary:computed-field"

AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Adventure extends LOI.Adventure
  onCreated: ->
    super arguments...
    
    @_initializeTasks()
    @_initializeInterests()
    @_initializeTapes()
  
  _initializeTasks: ->
    @currentTasks = new ComputedField => _.flatten (chapter.tasks for chapter in LOI.adventure.currentChapters())
  
  _initializeInterests: ->
    @currentInterests = new ComputedField =>
      completedTasks = _.filter LOI.adventure.currentTasks(), (task) => task.completed()
  
      _.union (task.interests() for task in completedTasks)...
  
  _initializeTapes: ->
    @tapesLocation = new PAA.Music.Tapes
    
    @tapesSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @tapesLocation
      
      return unless options.timelineId
      
      new LOI.Adventure.Situation options
    
    @currentTapes = new ComputedField =>
      return unless tapesSituation = @tapesSituation()
      
      tapeSelectors = tapesSituation.things()
      
      tapes = for tapeSelector in tapeSelectors
        PAA.Music.Tape.documents.findOne tapeSelector
      
      _.without tapes, undefined
