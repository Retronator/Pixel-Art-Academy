LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Shape extends LOI.Character.Avatar.Renderers.Renderer
  @liveEditing = true

  @_defaultSpriteIdsByName = {}

  @_getDefaultSpriteId: (name) ->
    return @_defaultSpriteIdsByName[name] if @_defaultSpriteIdsByName[name]

    if @liveEditing
      @_defaultSpriteIdsByName[name] = LOI.Assets.Sprite.documents.findOne({name})?._id

    else
      @_defaultSpriteIdsByName[name] = LOI.Assets.Sprite.findInCache({name})?._id

    @_defaultSpriteIdsByName[name]

  if @liveEditing and Meteor.isClient
    Meteor.startup =>
      # Subscribe to all character part sprites.
      types = LOI.Character.Part.allPartTypeIds()
      LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.subscribe types

  constructor: (@options, initialize) ->
    super arguments...

    # Prepare renderer only when it has been asked to initialize.
    return unless initialize

    # Shape renderer prepares all sprite directions and draws the one needed by the engine.
    @spriteDataInfo = {}
    @spriteData = {}
    @sprite = {}

    for field, side of LOI.Engine.RenderingSides.Keys
      do (side) =>
        # Sprites in flipped renderers need to come from the other side.
        sourceSide = if @options.flippedHorizontal then LOI.Engine.RenderingSides.mirrorSides[side] else side

        @spriteDataInfo[side] = new ComputedField =>
          spriteId = @options["#{sourceSide}SpriteId"]()
          flipped = false
          defaultSprite = false

          # If we didn't find a sprite for this side, we assume we should mirror the other side.
          unless spriteId
            mirrorSide = LOI.Engine.RenderingSides.mirrorSides[sourceSide]
            spriteId = @options["#{mirrorSide}SpriteId"]()
            flipped = true

          # If we still don't have a sprite, see if we have a default specified.
          unless spriteId
            if defaultName = @options.part.options.default
              spriteName = "#{defaultName} #{_.kebabCase sourceSide}"
              flipped = false
              defaultSprite = true

              spriteId = @constructor._getDefaultSpriteId spriteName

              unless spriteId
                spriteName = "#{defaultName} #{_.kebabCase mirrorSide}"
                flipped = true

                spriteId = @constructor._getDefaultSpriteId spriteName

          return unless spriteId

          if @constructor.liveEditing
            spriteData = LOI.Assets.Sprite.documents.findOne spriteId

          else
            spriteData = LOI.Assets.Sprite.getFromCache spriteId

          {spriteData, flipped, defaultSprite}

        @spriteData[side] = new ComputedField =>
          @spriteDataInfo[side]()?.spriteData

        @sprite[side] = new LOI.Assets.Engine.Sprite
          side: sourceSide
          spriteData: @spriteData[side]
          materialsData: @options.materialsData
          flippedHorizontal: new ComputedField =>
            if @spriteDataInfo[side]()?.flipped
              not @options.flippedHorizontal

            else
              @options.flippedHorizontal

    # By default we read the viewing angle from options, but we also support sending it late from the draw call.
    defaultViewingAngle = =>
      @options.viewingAngle?() or 0

    @viewingAngleGetter = new ReactiveField defaultViewingAngle, (a, b) => a is b

    @activeSide = new ComputedField => LOI.Engine.RenderingSides.getSideForAngle @viewingAngleGetter()()

    @activeSprite = new ComputedField =>
      @sprite[@activeSide()]

    @activeSpriteFlipped = new ComputedField =>
      @spriteDataInfo[@activeSide()]()?.flipped

    @activeSpriteIsDefault = new ComputedField =>
      @spriteDataInfo[@activeSide()]()?.defaultSprite

    @translation = new ComputedField =>
      sprite = @activeSprite()
      spriteData = sprite.options.spriteData()

      source = x: 0, y: 0
      target = x: 0, y: 0

      if origin = @options.origin
        source = (spriteData?.getLandmarkForName origin.landmark, @activeSpriteFlipped()) or source

        target.x = origin.x or 0
        target.y = origin.y or 0

      x: target.x - source.x
      y: target.y - source.y

    @_ready = new ComputedField =>
      # If we have no data, in this part, there's nothing to do.
      return true unless @options.part.options.dataLocation()
      
      # Shape is ready when the sprite is ready.
      @activeSprite().ready()

  ready: ->
    @_ready()
    
  landmarks: ->
    # Provide active sprite's landmarks, but translate them to the origin.
    return unless spriteData = @activeSprite().options.spriteData()

    # If there are no landmarks, there's nothing to do.
    return unless spriteData.landmarks

    translation = @translation()
    activeSpriteFlipped = @activeSpriteFlipped()

    landmarks = for landmark in spriteData.landmarks
      # Get potentially flipped landmark data.
      landmark = spriteData.getLandmarkForName landmark.name, activeSpriteFlipped
      
      _.extend {}, landmark,
        x: landmark.x + translation.x
        y: landmark.y + translation.y
        
    @_applyLandmarksRegion landmarks
    
    landmarks

  drawToContext: (context, options = {}) ->
    return unless @_shouldDraw(options) and @ready()

    # Update viewing angle.
    @viewingAngleGetter options.viewingAngle if options.viewingAngle

    # Don't draw default sprites (we only use them to provide landmarks).
    return if @activeSpriteIsDefault()

    sprite = @activeSprite()

    context.save()

    translation = @translation()
    context.translate translation.x, translation.y

    if @activeSpriteFlipped()
      context.translate 1, 0
      context.scale -1, 1

    sprite.drawToContext context, options
    context.restore()
