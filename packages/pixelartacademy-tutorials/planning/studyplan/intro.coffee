AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

StudyPlan = PAA.PixelPad.Apps.StudyPlan
Markup = PAA.Practice.Helpers.Drawing.Markup
InstructionsSystem = PAA.PixelPad.Systems.Instructions
InterfaceMarking = PAA.Tutorials.Planning.StudyPlan.InterfaceMarking

class PAA.Tutorials.Planning.StudyPlan.Intro
  class @PixelArtSoftwareNotCompleted extends PAA.Tutorials.Planning.StudyPlan.Instruction
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Intro.PixelArtSoftwareNotCompleted"
    
    @message: -> """
      Use the Study Plan to get an overview of your current tasks.
    """
    
    @delayDuration: -> 2
    
    @initialize()

    activeConditions: ->
      return unless studyPlan = @getStudyPlan()
      return if studyPlan.showProgression()
      
      return unless blueprint = @getBlueprint()
      
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
                x: 36, y: -40
              ,
                bezierControlPoints: [
                  x: 36, y: -35
                ,
                  x: 41, y: -27
                ]
                x: 46, y: -22
              ]
            text: _.extend {}, textBase,
              position:
                x: 36, y: -45, origin: Markup.TextOriginPosition.BottomCenter
              value: "Complete optional tutorials"
              align: Markup.TextAlign.Center
          ,
            line: _.extend {}, arrowBase,
              style: markupStyle
              points: [
                x: 103, y: -30
              ,
                bezierControlPoints: [
                  x: 96, y: -30
                ,
                  x: 88, y: -23
                ]
                x: 88, y: -13
              ]
            text: _.extend {}, textBase,
              position:
                x: 106, y: -30, origin: Markup.TextOriginPosition.MiddleLeft
              value: "Skip directly to the challenge"
              align: Markup.TextAlign.Left
          ]
      ]

  class @PixelArtSoftwareCompleted extends PAA.Tutorials.Planning.StudyPlan.Instruction
    optionalTutorialsMarkup: ->
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      interface:
        selector: "[data-goalid='#{PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.id()}'] .name-area"
        trackTarget: true
        bounds:
          x: 0
          y: 0
          width: 160
          height: 50
        markings: [
          line: _.extend {}, arrowBase,
            style: markupStyle
            points: [
              x: 80, y: 30
            ,
              bezierControlPoints: [
                x: 80, y: 25
              ,
                x: 80, y: 25
              ]
              x: 75, y: 15
            ]
          text: _.extend {}, textBase,
            position:
              x: 80, y: 35, origin: Markup.TextOriginPosition.TopCenter
            value: "Click on the goal name if you want\n to archive optional tutorials"
            align: Markup.TextAlign.Center
        ]
  
  class @PixelArtSoftwareCompletedBeforeSnakeAdded extends @PixelArtSoftwareCompleted
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Intro.PixelArtSoftwareCompletedBeforeSnakeAdded"
    
    @message: -> """
      You completed the Pixel Art Software goal and can now move on to your first project.
    """
    
    @delayDuration: -> 2
    
    @initialize()
    
    activeConditions: ->
      # Show when we're directly on the map.
      return unless blueprint = @getBlueprintWhenNoModalWindowDisplayed()

      # Show after Pixel art software is added and completed and until the Snake goal is added.
      return unless StudyPlan.hasGoal PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware
      return unless PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.completed()
      return if StudyPlan.hasGoal PAA.LearnMode.Intro.Tutorial.Goals.Snake

      # Wait for the expansion tile to be placed.
      return unless blueprint.roadTileMapComponent.isCreated()
      return unless tiles = blueprint.roadTileMapComponent.nonBlueprintTiles()
      return unless _.find tiles, (tile) => tile.data.type is StudyPlan.TileMap.Tile.Types.ExpansionPoint
      
      true
    
    markup: ->
      return unless studyPlan = @getStudyPlan()
      
      markupStyle = InterfaceMarking.defaultStyle()
      arrowBase = InterfaceMarking.arrowBase()
      textBase = InterfaceMarking.textBase()
      
      markup = []
      
      # Add text for optional tutorials.
      pixelArtSoftware = PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.getAdventureInstance()
      
      unless pixelArtSoftware.allCompleted() or StudyPlan.isGoalManuallyArchived(pixelArtSoftware)
        markup.push @optionalTutorialsMarkup()
            
      # Add text for adding a goal.
      unless StudyPlan.hasGoal(PAA.LearnMode.Intro.Tutorial.Goals.Snake) or studyPlan.addGoalOptions()
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

  class @PixelArtSoftwareCompletedAndSnakeAdded extends @PixelArtSoftwareCompleted
    @id: -> "PixelArtAcademy.Tutorials.Planning.StudyPlan.Intro.PixelArtSoftwareCompletedAndSnakeAdded"
    
    @message: -> """
      If you want to skip the rest of the Pixel Art Software tutorials,
      you can archive the goal so that its tasks don't appear in your to-do list.
    """
    
    @delayDuration: -> 2
    
    @initialize()
    
    activeConditions: ->
      return unless studyPlan = @getStudyPlan()
      return if studyPlan.showProgression()
      
      # Show after Snake is added and until the Elements of art goal is added.
      return unless StudyPlan.hasGoal PAA.LearnMode.Intro.Tutorial.Goals.Snake
      return if StudyPlan.hasGoal LM.PixelArtFundamentals.Fundamentals.Goals.ElementsOfArt
      
      # Only show until the Pixel art software is fully completed or archived
      return if PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.allCompleted() or StudyPlan.isGoalManuallyArchived PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware
      
      # If the Snake goal is completed, don't show this anymore, so the instruction for adding the next goal kicks in.
      return if PAA.LearnMode.Intro.Tutorial.Goals.Snake.completed()

      true
    
    markup: ->
      markup = []
      
      # Add text for optional tutorials.
      pixelArtSoftware = PAA.LearnMode.Intro.Tutorial.Goals.PixelArtSoftware.getAdventureInstance()
      
      unless pixelArtSoftware.allCompleted() or StudyPlan.isGoalManuallyArchived(pixelArtSoftware)
        markup.push @optionalTutorialsMarkup()
        
      markup
