AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion.DesignDocument extends PAA.Pico8.Cartridges.Invasion.DesignDocument
  @register @id()
  
  @Options =
    Directions:
      Up: 'Up'
      Down: 'Down'
      Left: 'Left'
      Right: 'Right'
    Orientations:
      Horizontal: 'Horizontal'
      Vertical: 'Vertical'
    HorizontalAlignments:
      Left: 'Left'
      Center: 'Center'
      Right: 'Right'
    VerticalAlignments:
      Top: 'Top'
      Middle: 'Middle'
      Bottom: 'Bottom'
    Sides:
      Top: 'Top'
      Bottom: 'Bottom'
      Left: 'Left'
      Right: 'Right'
    Themes:
      ScienceFiction: 'ScienceFiction'
      DeepSea: 'DeepSea'
      CosmicHorror: 'CosmicHorror'
      MicroscopicWorld: 'MicroscopicWorld'
    Entities:
      Defender: 'Defender'
      Invader: 'Invader'
      DefenderProjectile: 'DefenderProjectile'
      InvaderProjectile: 'InvaderProjectile'
      DefenderProjectileExplosion: 'DefenderProjectileExplosion'
      InvaderProjectileExplosion: 'InvaderProjectileExplosion'
      Shield: 'Shield'
    PostponeGameplay:
      None: 'None'
      UntilSpawnedAll: 'UntilSpawnedAll'
    DeathTypes:
      Disappear: 'Disappear'
      Explode: 'Explode'
    Defender:
      Movements:
        Horizontal: 'Horizontal'
        Vertical: 'Vertical'
        AllDirections: 'AllDirections'
    Invaders:
      Formation:
        MovementTypes:
          Individual: 'Individual'
          All: 'All'
        
  @Texts =
    Directions:
      Up: 'up'
      Down: 'down'
      Left: 'left'
      Right: 'right'
    Themes:
      ScienceFiction: "science fiction"
      DeepSea: "the deep sea"
      CosmicHorror: "cosmic horror"
      MicroscopicWorld: "the microscopic world"
    PostponeGameplay:
      None: 'starts immediately'
      UntilSpawnedAll: 'pauses during this time'
    GameFlow:
      StartingAlignments:
        TopLeft: 'top-left corner'
        TopCenter: 'top side'
        TopRight: 'top-right corner'
        MiddleLeft: 'left side'
        MiddleCenter: 'center'
        MiddleRight: 'right side'
        BottomLeft: 'bottom-left corner'
        BottomCenter: 'bottom side'
        BottomRight: 'bottom-right corner'
      Defender:
        Movements:
          Horizontal: 'left and right'
          Vertical: 'up and down'
          AllDirections: "in all 4 directions"
      DefenderProjectiles:
        InvaderDeathTypes:
          Disappear: 'disappear'
          Explode: 'explode'
        LevelUp:
          IncreaseShootingFrequency: 'shoot more frequently'
          IncreaseScore: 'score more points'
          StayTheSame: 'stay the same'
      Invaders:
        Formation:
          Appearing:
            Individual: 'one by one'
            All: 'all at once'
          MovementTypes:
            Individual: 'one by one'
            All: 'in unison'
          MovementOrientations:
            Horizontal: 'left and right'
            Vertical: 'up and down'
          AttackDirections:
            Up: 'ascend up'
            Down: 'descend down'
            Left: 'advance left'
            Right: 'advance right'
            NoHorizontal: 'do not move horizontally'
            NoVertical: 'do not move vertically'
      InvaderProjectiles:
        DefenderDeathTypes:
          Disappear: 'disappears'
          Explode: 'explodes'
        LevelUp:
          IncreaseShootingFrequency: 'shoot more frequently'
          IncreaseScore: 'score more points'
          StayTheSame: 'stay the same'
          
  @DesignSchema =
    theme: @Options.Themes
    entities: [@Options.Entities]
    postponeGameplay: @Options.PostponeGameplay
    defender:
      movement: @Options.Defender.Movements
      startingAlignment:
        horizontal: @Options.HorizontalAlignments
        vertical: @Options.VerticalAlignments
      deathType: @Options.DeathTypes
    defenderProjectiles:
      direction: @Options.Directions
    invaders:
      formation:
        startingAlignment:
          horizontal: @Options.HorizontalAlignments
          vertical: @Options.VerticalAlignments
        movementType: @Options.Invaders.Formation.MovementTypes
        movementOrientation: @Options.Orientations
        attackDirection: @Options.Directions
      deathType: @Options.DeathTypes
    invaderProjectiles:
      direction: @Options.Directions
    shields:
      side: @Options.Sides
      
  @DesignDefaults =
    lives: 3
    postponeGameplay: @Options.PostponeGameplay.UntilSpawnedAll
    defender:
      movement: @Options.Defender.Movements.Horizontal
      startingAlignment:
        horizontal: @Options.HorizontalAlignments.Left
        vertical: @Options.VerticalAlignments.Bottom
      speed: 1
      deathType: @Options.DeathTypes.Explode
    defenderProjectiles:
      direction: @Options.Directions.Up
      speed: 2
      maxCount: 1
    invaders:
      formation:
        rows: 3
        columns: 7
        horizontalSpacing: 2
        verticalSpacing: 2
        startingAlignment:
          horizontal: @Options.HorizontalAlignments.Center
          vertical: @Options.VerticalAlignments.Top
        movementType: @Options.Invaders.Formation.MovementTypes.Individual
        movementOrientation: @Options.Orientations.Horizontal
        attackDirection: @Options.Directions.Down
        horizontalSpeed: 2
        verticalSpeed: 8
        spawnDelay: 0.01
        shooting:
          timeoutFull: 3
          timeoutFullDecreasePerLevel: 0.5
          timeoutEmpty: 1
          variability: 0.25
      scorePerInvader: 10
      scoreIncreasePerInvaderPerLevel: 10
      deathType: @Options.DeathTypes.Explode
    invaderProjectiles:
      direction: @Options.Directions.Down
      speed: 1
      maxCount: 3
    shields:
      amount: 4
      spacing: 16
      side: @Options.Sides.Bottom
  
  hasEntity: (entity) ->
    entity in (@getDesignValue('entities') or [])
  
  hasEntities: ->
    @getDesignValue('entities')?.length
  
  themeChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.Themes)
    property: 'theme'
    
  gameFlowDefenderMovementChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.GameFlow.Defender.Movements)
    property: 'defender.movement'
  
  gameFlowDefenderStartingAlignmentPrepositionAt: ->
    return unless horizontalAlignment = @getDesignValue 'defender.startingAlignment.horizontal'
    return unless verticalAlignment = @getDesignValue 'defender.startingAlignment.vertical'
    @_gameFlowStartingAlignmentPrepositionAt horizontalAlignment, verticalAlignment
    
  _gameFlowStartingAlignmentPrepositionAt: (horizontalAlignment, verticalAlignment) ->
    # We need 'at' (insted of 'in') when we are at a side and not in the corner/center.
    center = horizontalAlignment is @constructor.Options.HorizontalAlignments.Center
    middle = verticalAlignment is @constructor.Options.VerticalAlignments.Middle
    
    (center or middle) and not (center and middle)
  
  gameFlowDefenderStartingAlignmentChoice: ->
    @_gameFlowStartingAlignmentChoice 'defender'
  
  _gameFlowStartingAlignmentChoice: (property) ->
    options = for value, text of @constructor.Texts.GameFlow.StartingAlignments
      alignments = value.match /[A-Z][a-z]*/g
      
      value: value
      text: text
      designValues:
        "#{property}.startingAlignment.horizontal": alignments[1]
        "#{property}.startingAlignment.vertical": alignments[0]
      
    options: options
    value: =>
      return unless horizontalAlignment = @getDesignValue "#{property}.startingAlignment.horizontal"
      return unless verticalAlignment = @getDesignValue "#{property}.startingAlignment.vertical"

      "#{verticalAlignment}#{horizontalAlignment}"
      
  gameFlowDefenderProjectilesDirectionChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.Directions)
    property: 'defenderProjectiles.direction'
  
  gameFlowDefenderProjectilesOrientationVertical: ->
    defenderProjectilesDirection = @getDesignValue 'defenderProjectiles.direction'
    defenderProjectilesDirection in [@constructor.Options.Directions.Up, @constructor.Options.Directions.Down]
  
  gameFlowDefenderProjectilesInvadersDeathTypeChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.GameFlow.DefenderProjectiles.InvaderDeathTypes)
    property: 'invaders.deathType'
  
  gameFlowDefenderProjectilesInvadersLevelUpChoice: ->
    options = [
      value: 'IncreaseShootingFrequency'
      text: @constructor.Texts.GameFlow.DefenderProjectiles.LevelUp.IncreaseShootingFrequency
      designValues:
        "invaders.formation.shooting.timeoutFullDecreasePerLevel": @constructor.DesignDefaults.invaders.formation.shooting.timeoutFullDecreasePerLevel
        "invaders.scoreIncreasePerInvaderPerLevel": 0
    ,
      value: 'IncreaseScore'
      text: @constructor.Texts.GameFlow.DefenderProjectiles.LevelUp.IncreaseScore
      designValues:
        "invaders.formation.shooting.timeoutFullDecreasePerLevel": 0
        "invaders.scoreIncreasePerInvaderPerLevel": @constructor.DesignDefaults.invaders.scoreIncreasePerInvaderPerLevel
    ,
      value: 'StayTheSame'
      text: @constructor.Texts.GameFlow.DefenderProjectiles.LevelUp.StayTheSame
      designValues:
        "invaders.formation.shooting.timeoutFullDecreasePerLevel": 0
        "invaders.scoreIncreasePerInvaderPerLevel": 0
    ]
    
    options: options
    value: =>
      return 'IncreaseShootingFrequency' if @getDesignValue 'invaders.formation.shooting.timeoutFullDecreasePerLevel'
      return 'IncreaseScore' if @getDesignValue 'invaders.scoreIncreasePerInvaderPerLevel'
      'StayTheSame'
  
  gameFlowInvadersStartingAlignmentPrepositionAt: ->
    return unless horizontalAlignment = @getDesignValue 'invaders.formation.startingAlignment.horizontal'
    return unless verticalAlignment = @getDesignValue 'invaders.formation.startingAlignment.vertical'
    @_gameFlowStartingAlignmentPrepositionAt horizontalAlignment, verticalAlignment
  
  gameFlowInvadersFormationStartingAlignmentChoice: ->
    @_gameFlowStartingAlignmentChoice 'invaders.formation'
  
  gameFlowInvadersFormationAppearingChoice: ->
    options = [
      value: 'All'
      text: @constructor.Texts.GameFlow.Invaders.Formation.Appearing.All
      designValues:
        "invaders.formation.spawnDelay": 0
    ,
      value: 'Individual'
      text: @constructor.Texts.GameFlow.Invaders.Formation.Appearing.Individual
      designValues:
        "invaders.formation.spawnDelay": @constructor.DesignDefaults.invaders.formation.spawnDelay
    ]
    
    options: options
    value: =>
      spawnDelay = @getDesignValue 'invaders.formation.spawnDelay'
      return unless spawnDelay?

      if spawnDelay then 'Individual' else 'All'
  
  gameFlowInvadersFormationAppearingOneByOne: ->
    @getDesignValue 'invaders.formation.spawnDelay'
  
  gameFlowInvadersPostponeGameplayChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.PostponeGameplay)
    property: 'postponeGameplay'
  
  gameFlowInvadersFormationMovementOrientationChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.GameFlow.Invaders.Formation.MovementOrientations)
    property: 'invaders.formation.movementOrientation'
  
  gameFlowInvadersFormationAttackDirectionChoice: ->
    movementOrientation = @getDesignValue 'invaders.formation.movementOrientation'

    if movementOrientation is @constructor.Options.Orientations.Horizontal
      options = [
        value: 'Up'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.Up
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Up
          'invaders.formation.verticalSpeed': @constructor.DesignDefaults.invaders.formation.verticalSpeed
      ,
        value: 'Down'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.Down
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Down
          'invaders.formation.verticalSpeed': @constructor.DesignDefaults.invaders.formation.verticalSpeed
      ,
        value: 'NoVertical'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.NoVertical
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Down
          'invaders.formation.verticalSpeed': 0
      ]
    
    else
      options = [
        value: 'Left'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.Left
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Left
          'invaders.formation.horizontalSpeed': @constructor.DesignDefaults.invaders.formation.horizontalSpeed
      ,
        value: 'Right'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.Right
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Right
          'invaders.formation.horizontalSpeed': @constructor.DesignDefaults.invaders.formation.horizontalSpeed
      ,
        value: 'NoHorizontal'
        text: @constructor.Texts.GameFlow.Invaders.Formation.AttackDirections.NoHorizontal
        designValues:
          'invaders.formation.attackDirection': @constructor.Options.Directions.Left
          'invaders.formation.horizontalSpeed': 0
      ]
    
    options: options
    value: =>
      return unless movementOrientation = @getDesignValue 'invaders.formation.movementOrientation'
      attackDirection = @getDesignValue 'invaders.formation.attackDirection'
      horizontalSpeed = @getDesignValue 'invaders.formation.horizontalSpeed'
      verticalSpeed = @getDesignValue 'invaders.formation.verticalSpeed'
      
      if movementOrientation is @constructor.Options.Orientations.Horizontal
        return unless verticalSpeed?
        return 'NoVertical' if verticalSpeed is 0
        return unless attackDirection
        if attackDirection is @constructor.Options.Directions.Up then 'Up' else 'Down'

      else
        return unless horizontalSpeed?
        return 'NoHorizontal' if horizontalSpeed is 0
        return unless attackDirection
        if attackDirection is @constructor.Options.Directions.Left then 'Left' else 'Right'
  
  gameFlowInvadersFormationMovementTypeChoice: ->
    options = ({value, text} for value, text of @constructor.Texts.GameFlow.Invaders.Formation.MovementTypes)
    
    individualOption = _.find options, (option) => option.value is @constructor.Options.Invaders.Formation.MovementTypes.Individual
    individualOption.designValues =
      'invaders.formation.movementType': @constructor.Options.Invaders.Formation.MovementTypes.Individual
      'invaders.formation.horizontalSpeed': @getDesignValue('invaders.formation.horizontalSpeed') ? @constructor.DesignDefaults.invaders.formation.horizontalSpeed
      'invaders.formation.verticalSpeed': @getDesignValue('invaders.formation.verticalSpeed') ? @constructor.DesignDefaults.invaders.formation.verticalSpeed
    
    movementOrientation = @getDesignValue 'invaders.formation.movementOrientation'
    
    allOption = _.find options, (option) => option.value is @constructor.Options.Invaders.Formation.MovementTypes.All
    allOption.designValues =
      'invaders.formation.movementType': @constructor.Options.Invaders.Formation.MovementTypes.All
      'invaders.formation.horizontalSpeed': @getDesignValue('invaders.formation.horizontalSpeed') ? @constructor.DesignDefaults.invaders.formation.horizontalSpeed / if movementOrientation is @constructor.Options.Orientations.Horizontal then 10 else 1
      'invaders.formation.verticalSpeed': @getDesignValue('invaders.formation.verticalSpeed') ? @constructor.DesignDefaults.invaders.formation.verticalSpeed / if movementOrientation is @constructor.Options.Orientations.Vertical then 10 else 1
    
    options: options
    property: 'invaders.formation.movementType'
  
  gameFlowInvadersFormationMovementType: -> @getDesignValue 'invaders.formation.movementType'
  
  gameFlowInvaderProjectilesDirectionChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.Directions)
    property: 'invaderProjectiles.direction'
  
  gameFlowInvaderProjectilesDefenderDeathTypeChoice: ->
    options: ({value, text} for value, text of @constructor.Texts.GameFlow.InvaderProjectiles.DefenderDeathTypes)
    property: 'defender.deathType'
  
  Component = @
  
  class @Lives extends @Property
    @register "#{Component.id()}.Lives"
    property: -> 'lives'
    
  class @DefenderSpeed extends @Property
    @register "#{Component.id()}.DefenderSpeed"
    property: -> 'defender.speed'
    
  class @DefenderProjectilesSpeed extends @Property
    @register "#{Component.id()}.DefenderProjectilesSpeed"
    property: -> 'defenderProjectiles.speed'
    
  class @DefenderProjectilesMaxCount extends @Property
    @register "#{Component.id()}.DefenderProjectilesMaxCount"
    property: -> 'defenderProjectiles.maxCount'
    
  class @InvadersFormationRows extends @Property
    @register "#{Component.id()}.InvadersFormationRows"
    property: -> 'invaders.formation.rows'
    
  class @InvadersFormationColumns extends @Property
    @register "#{Component.id()}.InvadersFormationColumns"
    property: -> 'invaders.formation.columns'
    
  class @InvadersFormationHorizontalSpacing extends @Property
    @register "#{Component.id()}.InvadersFormationHorizontalSpacing"
    property: -> 'invaders.formation.horizontalSpacing'
    
  class @InvadersFormationVerticalSpacing extends @Property
    @register "#{Component.id()}.InvadersFormationVerticalSpacing"
    property: -> 'invaders.formation.verticalSpacing'
    
  class @InvadersFormationHorizontalSpeed extends @Property
    @register "#{Component.id()}.InvadersFormationHorizontalSpeed"
    property: -> 'invaders.formation.horizontalSpeed'
    
  class @InvadersFormationVerticalSpeed extends @Property
    @register "#{Component.id()}.InvadersFormationVerticalSpeed"
    property: -> 'invaders.formation.verticalSpeed'
    
  class @InvadersFormationSpawnDelay extends @Property
    @register "#{Component.id()}.InvadersFormationSpawnDelay"
    property: -> 'invaders.formation.spawnDelay'
    
  class @InvadersFormationShootingTimeoutFull extends @Property
    @register "#{Component.id()}.InvadersFormationShootingTimeoutFull"
    property: -> 'invaders.formation.shooting.timeoutFull'
    
  class @InvadersFormationShootingTimoutEmpty extends @Property
    @register "#{Component.id()}.InvadersFormationShootingTimoutEmpty"
    property: -> 'invaders.formation.shooting.timeoutEmpty'
    
  class @InvadersFormationTimeoutFullDecreasePerLevel extends @Property
    @register "#{Component.id()}.InvadersFormationTimeoutFullDecreasePerLevel"
    property: -> 'invaders.formation.shooting.timeoutFullDecreasePerLevel'
    
  class @InvadersFormationShootingVariability extends @Property
    @register "#{Component.id()}.InvadersFormationShootingVariability"
    property: -> 'invaders.formation.shooting.variability'
    
    load: ->
      Math.round super() * 100
      
    save: (value) ->
      super value / 100
    
  class @InvadersScorePerInvader extends @Property
    @register "#{Component.id()}.InvadersScorePerInvader"
    property: -> 'invaders.scorePerInvader'

  class @InvadersScoreIncreasePerInvaderPerLevel extends @Property
    @register "#{Component.id()}.InvadersScoreIncreasePerInvaderPerLevel"
    property: -> 'invaders.scoreIncreasePerInvaderPerLevel'

  class @InvaderProjectilesSpeed extends @Property
    @register "#{Component.id()}.InvaderProjectilesSpeed"
    property: -> 'invaderProjectiles.speed'
  
  class @InvaderProjectilesMaxCount extends @Property
    @register "#{Component.id()}.InvaderProjectilesMaxCount"
    property: -> 'invaderProjectiles.maxCount'
