AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = StudyPlan.InterfaceMarking

class StudyPlan.Instructions
  class @Instruction extends PAA.Tutorials.Planning.Instructions.Instruction
    @activeDisplayState: ->
      # We only have markup without a message.
      InstructionsSystem.DisplayState.Hidden
    
    getBlueprintWhenNoTaskIsHovered: ->
      return unless blueprint = @getBlueprint()
      return if blueprint.hoveredTaskId()
      blueprint
      
  class @Choices extends @Instruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.Choices"
    
    @initialize()
    
    @delayDuration: -> 2
    
    activeConditions: ->
      return unless blueprint = @getBlueprintWhenNoTaskIsHovered()
      
      # Show when helpers and pixel art software challenge are not completed.
      return if PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.Helpers.completed() or PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.CopyReference.completed()
      
      # Wait until the map is revealed.
      blueprint.initialRevealCompleted()
      
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: "[data-goalid='#{PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.id()}']"
          trackTarget: true
          bounds:
            x: -60
            y: -70
            width: 300
            height: 100
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 20, y: -40
              ,
                bezierControlPoints: [
                  x: 20, y: -35
                ,
                  x: 25, y: -27
                ]
                x: 30, y: -22
              ]
            text: _.extend {}, textBase,
              position:
                x: 20, y: -45, origin: Markup.TextOriginPosition.BottomCenter
              value: "Complete optional tutorials"
              align: Markup.TextAlign.Center
          ,
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 87, y: -30
              ,
                bezierControlPoints: [
                  x: 80, y: -30
                ,
                  x: 72, y: -23
                ]
                x: 72, y: -13
              ]
            text: _.extend {}, textBase,
              position:
                x: 90, y: -30, origin: Markup.TextOriginPosition.MiddleLeft
              value: "Skip directly to the challenge"
              align: Markup.TextAlign.Left
          ]
      ]
  
  class @Completing extends @Instruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.Completing"
    
    @initialize()
    
    @delayDuration: -> 2
    
    constructor: ->
      super arguments...
      
      @flagChangedCount = new ReactiveField 0
      
      @_flagChangedAutorun = new Tracker.autorun (computation) =>
        return unless flagTile = @getFlagTile()
        return unless @activeConditions()
        flagRaised = flagTile.flagRaised()
        
        unless @_flagRaised?
          @_flagRaised = flagRaised
          return
          
        return if flagRaised is @_flagRaised
        @_flagRaised = flagRaised
        
        @flagChangedCount @flagChangedCount() + 1
        
    destroy: ->
      super arguments...
      
      @_flagChangedAutorun.stop()
    
    activeConditions: ->
      return unless blueprint = @getBlueprintWhenNoTaskIsHovered()
      
      # Show after Pixel Art Software is completed and until the Snake goal is added and completed.
      return unless PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.completed()
      return if LM.Intro.Tutorial.Goals.Snake.completed() and StudyPlan.hasGoal LM.Intro.Tutorial.Goals.Snake

      # Wait for the flag tile to be revealed.
      return unless flagTile = @getFlagTile()
      return unless flagTile.revealed()

      unless StudyPlan.hasGoal PAA.LearnMode.Intro.Tutorial.Goals.Snake
        # Wait for the expansion tile to be placed.
        return unless blueprint.roadTileMapComponent.isCreated()
        return unless tiles = blueprint.roadTileMapComponent.nonBlueprintTiles()
        return unless _.find tiles, (tile) => tile.data.type is StudyPlan.TileMap.Tile.Types.ExpansionPoint
        
      true
      
    getFlagTile: ->
      return unless pixelArtSoftwareGoalComponent = @getGoalComponent PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware
      return unless tiles = pixelArtSoftwareGoalComponent.tileMapComponent.nonBlueprintTiles()
      _.find tiles, (tile) => tile.data.type is StudyPlan.TileMap.Tile.Types.Flag
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      markup = []
      
      # Add text for the flag.
      pixelArtSoftware = PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.getAdventureInstance()
      markedComplete = StudyPlan.isGoalMarkedComplete pixelArtSoftware
      
      if @flagChangedCount() < 2
        if pixelArtSoftware.allCompleted()
          flagText = "Click on the flag pole\nto mark this goal complete" unless markedComplete
          
        else
          if markedComplete
            flagText = "Click on the flag\nto show optional tutorials again"
            
          else
            flagText = "Click on the flag pole\nto hide optional tutorials"
  
        if flagText
          markup.push
            interface:
              selector: "[data-goalid='#{PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.id()}'] .tile.flag.revealed"
              trackTarget: true
              bounds:
                x: -50
                y: -70
                width: 120
                height: 60
              markings: [
                line: _.extend {}, arrowBase,
                  style: markupStyle
                  points: [
                    x: 8, y: -45
                  ,
                    bezierControlPoints: [
                      x: 5, y: -35
                    ,
                      x: 5, y: -25
                    ]
                    x: 5, y: -15
                  ]
                text: _.extend {}, textBase,
                  position:
                    x: 10, y: -50, origin: Markup.TextOriginPosition.BottomCenter
                  value: flagText
                  align: Markup.TextAlign.Center
              ]
            
      # Add text for adding a goal.
      unless StudyPlan.hasGoal(PAA.LearnMode.Intro.Tutorial.Goals.Snake) or @getStudyPlan().addGoalOptions()
        markup.push
          interface:
            selector: ".tile.expansion-point"
            trackTarget: true
            bounds:
              x: 0
              y: -50
              width: 120
              height: 60
            markings: [
              line: _.extend {}, arrowBase,
                style: markupStyle
                points: [
                  x: 60, y: -15
                ,
                  bezierControlPoints: [
                    x: 60, y: -5
                  ,
                    x: 40, y: 0
                  ]
                  x: 28, y: 0
                ]
              text: _.extend {}, textBase,
                position:
                  x: 60, y: -20, origin: Markup.TextOriginPosition.BottomCenter
                value: "Click on the arrow\nto continue to a new goal"
                align: Markup.TextAlign.Center
            ]
        
      markup
  
  class @ExpansionPointInstruction extends @Instruction
    @delayDuration: -> @defaultDelayDuration
    
    hasExpansionPointInDirectionWithGoalType: (expansionDirection, goalType) ->
      return unless blueprint = @getBlueprintWhenNoTaskIsHovered()
      
      # Show until add new goal is selected.
      return if @getStudyPlan().addGoalOptions()
      
      # Show after Snake goal is completed.
      return unless LM.Intro.Tutorial.Goals.Snake.completed()
      
      # Wait for the expansion tile to be placed.
      return unless blueprint.roadTileMapComponent.isCreated()
      return unless tiles = blueprint.roadTileMapComponent.nonBlueprintTiles()
      tiles = _.filter tiles, (tile) => tile.data.type is StudyPlan.TileMap.Tile.Types.ExpansionPoint and tile.data.expansionDirection is expansionDirection
      
      for tile in tiles when tile.data.connectionPoint
        # Skip expansion points from mid-term goals.
        continue if StudyPlan.getGoalType(tile.data.connectionPoint?.goalId) is StudyPlan.GoalTypes.MidTerm

        for goalId in _.flatten tile.data.goalIds
          return true if StudyPlan.getGoalType(goalId) is goalType
      
      false

  class @ForwardShortTerm extends @ExpansionPointInstruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.ForwardShortTerm"
    
    @initialize()
    
    activeConditions: -> @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Forward, StudyPlan.GoalTypes.ShortTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.forward.short-term"
          trackTarget: true
          bounds:
            x: 0
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 60, y: -12
              ,
                bezierControlPoints: [
                  x: 60, y: -2
                ,
                  x: 40, y: 3
                ]
                x: 28, y: 3
              ]
            text: _.extend {}, textBase,
              position:
                x: 60, y: -17, origin: Markup.TextOriginPosition.BottomCenter
              value: "Add a new goal\nto continue to"
              align: Markup.TextAlign.Center
          ]
      ]
  
  class @SidewaysShortTerm extends @ExpansionPointInstruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.SidewaysShortTerm"
    
    @initialize()
    
    activeConditions: -> @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Sideways, StudyPlan.GoalTypes.ShortTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.sideways.short-term"
          trackTarget: true
          bounds:
            x: -60
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: -15, y: -30
              ,
                bezierControlPoints: [
                  x: -15, y: -25
                ,
                  x: -10, y: -17
                ]
                #x: 30, y: -22
                x: -5, y: -12
              ]
            text: _.extend {}, textBase,
              position:
                x: -15, y: -35, origin: Markup.TextOriginPosition.BottomCenter
              value: "You can now continue to\na new goal in parallel"
              align: Markup.TextAlign.Center
          ]
      ]
      
  class @ForwardMidTerm extends @ExpansionPointInstruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.ForwardMidTerm"
    
    @initialize()
    
    activeConditions: -> @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Forward, StudyPlan.GoalTypes.MidTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.forward.mid-term"
          trackTarget: true
          bounds:
            x: 0
            y: -50
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 60, y: -12
              ,
                bezierControlPoints: [
                  x: 60, y: -2
                ,
                  x: 40, y: 3
                ]
                x: 28, y: 3
              ]
            text: _.extend {}, textBase,
              position:
                x: 60, y: -17, origin: Markup.TextOriginPosition.BottomCenter
              value: "See what goals you can\ncontinue to after"
              align: Markup.TextAlign.Center
          ]
      ]

  class @SidewaysMidTerm extends @ExpansionPointInstruction
    @id: -> "PixelArtAcademy.PixelPad.Apps.StudyPlan.Instructions.SidewaysMidTerm"
    
    @initialize()
    
    activeConditions: -> @hasExpansionPointInDirectionWithGoalType StudyPlan.GoalConnectionDirections.Sideways, StudyPlan.GoalTypes.MidTerm
    
    markup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      [
        interface:
          selector: ".expansion-point.sideways.mid-term"
          trackTarget: true
          bounds:
            x: 0
            y: -70
            width: 120
            height: 60
          markings: [
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 27, y: -25
              ,
                bezierControlPoints: [
                  x: 20, y: -25
                ,
                  x: 15, y: -20
                ]
                x: 10, y: -15
              ]
            text: _.extend {}, textBase,
              position:
                x: 30, y: -25, origin: Markup.TextOriginPosition.MiddleLeft
              value: "You can plan ahead\nand add a goal in parallel"
              align: Markup.TextAlign.Left
          ]
      ]
