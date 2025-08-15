LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pico8.Cartridges.Invasion extends PAA.Pico8.Cartridge
  # cartridgeRan: whether the cartridge has ever been started
  # highestLevelCompleted: the highest level the player completed
  # highScore: the top result the player has achieved
  @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion'
  
  @gameSlug: -> 'invasion'
  @projectClass: -> @Project

  @initialize()
  
  startParameter: ->
    PAA.Pico8.Cartridges.Invasion.DesignDocument.designStringForProjectId @projectId()

  onInputOutput: (address, value) ->
    return unless value?
    
    switch address
      # Running the cartridge
      when 1
        @state 'cartridgeRan', true

      # Level completed
      when 2
        highestLevelCompleted = @state('highestLevelCompleted') or 0
        return unless value > highestLevelCompleted
        
        @state 'highestLevelCompleted', value
        
      # Score achieved
      when 3
        @_newScore = value
      
      when 4
        @_newScore += value << 8
        highScore = @state('highScore') or 0
        return unless @_newScore > highScore
    
        @state 'highScore', @_newScore
  
  # Assets

  class @Sprite extends PAA.Practice.Project.Asset.Bitmap
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Pico8
    
    @backgroundColor: ->
      paletteColor:
        ramp: 0
        shade: 0
    
    @availablePublications: ->
      LM.Design.Fundamentals.Publications.getChronoscopeIds().publications
  
  class @Defender extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Defender'
    
    @displayName: -> "Defender"
    
    @description: -> """
      The player unit tasked to defend from the incoming invasion.
    """
    
    @fixedDimensions: -> width: 16, height: 16
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/defender.png'
    
    @initialize()
  
  class @DefenderProjectile extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DefenderProjectile'
    
    @displayName: -> "Defender projectile"
    
    @description: -> """
      The projectile that the defender shoots at the invaders.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/defender-projectile.png'
    
    @initialize()
  
  class @DefenderProjectileExplosion extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.DefenderProjectileExplosion'
    
    @displayName: -> "Defender projectile explosion"
    
    @description: -> """
      The explosion that appears when the defender projectile hits something.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/defender-projectile-explosion.png'
    
    @initialize()
    
  class @Invader extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Invader'
    
    @displayName: -> "Invader"
    
    @description: -> """
      The enemy unit that is attacking the defender.
    """
    
    @fixedDimensions: -> width: 16, height: 16
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/invader.png'
    
    @initialize()
  
  class @InvaderProjectile extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.InvaderProjectile'
    
    @displayName: -> "Invader projectile"
    
    @description: -> """
      The projectile that the invaders shoot at the defender.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/invader-projectile.png'
    
    @initialize()
  
  class @InvaderProjectileExplosion extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.InvaderProjectileExplosion'
    
    @displayName: -> "Invader projectile explosion"
    
    @description: -> """
      The explosion that appears when the invader projectile hits something.
    """
    
    @fixedDimensions: -> width: 8, height: 8
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/invader-projectile-explosion.png'
    
    @initialize()
    
  class @Shield extends @Sprite
    @id: -> 'PixelArtAcademy.Pico8.Cartridges.Invasion.Shield'
    
    @displayName: -> "Shield"
    
    @description: -> """
      An obstacle that blocks projectiles until it gets destroyed.
    """
    
    @fixedDimensions: -> width: 24, height: 24
    
    @imageUrl: -> '/pixelartacademy/pico8/cartridges/invasion/sprites/shield.png'
    
    @initialize()
