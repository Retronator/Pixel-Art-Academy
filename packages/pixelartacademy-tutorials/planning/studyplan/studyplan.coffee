LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlanApp = PAA.PixelPad.Apps.StudyPlan
InstructionsSystem = PAA.PixelPad.Systems.Instructions

class PAA.Tutorials.Planning.StudyPlan
  class @Instruction extends PAA.Tutorials.Planning.Instructions.Instruction
    modalWindowDisplayed: ->
      return unless studyPlan = @getStudyPlan()
      studyPlan.modalWindowDisplayed()
    
    getBlueprintWhenNoModalWindowDisplayed: ->
      return if @modalWindowDisplayed()
      @getBlueprint()
      
  class @MarkupInstruction extends @Instruction
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayStates.Hidden

  class @ExpansionPointInstruction extends @Instruction
    hasExpansionPointInDirectionWithGoalType: (expansionDirection, goalType) ->
      return unless blueprint = @getBlueprint()
      
      # Wait for the expansion tile to be placed.
      return unless blueprint.roadTileMapComponent.isCreated()
      return unless tiles = blueprint.roadTileMapComponent.nonBlueprintTiles()
      tiles = _.filter tiles, (tile) => tile.data.type is StudyPlanApp.TileMap.Tile.Types.ExpansionPoint and tile.data.expansionDirection is expansionDirection
      
      for tile in tiles when tile.data.connectionPoint
        # Skip expansion points from mid-term goals.
        continue if StudyPlanApp.getGoalType(tile.data.connectionPoint?.goalId) is StudyPlanApp.GoalTypes.MidTerm

        for goalId in _.flatten tile.data.goalIds
          return true if StudyPlanApp.getGoalType(goalId) is goalType
      
      false
