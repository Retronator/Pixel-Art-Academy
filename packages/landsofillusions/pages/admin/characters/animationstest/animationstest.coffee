AB = Artificial.Base
AM = Artificial.Mirage
AS = Artificial.Spectrum
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.AnimationsTest extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Characters.AnimationsTest'
  @register @id()

  @version: ->
    '0.1'

  constructor: (@options) ->
    super arguments...

    # Prepare all reactive fields.
    @rendererManager = new ReactiveField null
    @sceneManager = new ReactiveField null

  onCreated: ->
    super arguments...

    # Subscribe to templates.
    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 250
      safeAreaHeight: 100
      minScale: 3

    @app = @ancestorComponentOfType Artificial.Base.App
    @app.addComponent @

    # Prepare avatar URLs.
    bodyNames = [
      'ectomorph'
      'mesomorph'
      'endomorph'
      'female-ectomorph2'
      'female-ectomorph3'
      'female-mesomorph1'
      'female-mesomorph2'
      'female-mesomorph3'
      'female-endomorph1'
      'female-endomorph2'
      'female-endomorph4'
      'female-endomorph5'
      'male-ectomorph1'
      'male-mesomorph3'
      'male-endomorph2'
      'male-endomorph3'
      'male-endomorph4'
    ]

    bodyTypeUrls = for bodyName in bodyNames
      @versionedUrl "/packages/retronator_landsofillusions/pages/admin/characters/outfitstest/bodies/#{bodyName}.json"

    pixelArtAcademyActors = ['ace', 'jaxx', 'lisa', 'mae', 'saanvi', 'ty']
    pixelArtAcademyActorUrls = for actor in pixelArtAcademyActors
      @versionedUrl "/pixelartacademy/actors/#{actor}.json"

    retronatorHQActors = ['alexandra', 'burra', 'corinne', 'retro', 'reuben', 'shelley']
    retronatorHQActorUrls = for actor in retronatorHQActors
      @versionedUrl "/retronator/hq/actors/#{actor}.json"

    avatarUrls = [pixelArtAcademyActorUrls...]
    @charactersCount = avatarUrls.length

    # Initialize components.
    @sceneManager new @constructor.SceneManager @

    rendererManager = new @constructor.RendererManager @
    @rendererManager rendererManager

    @testAnimationName = new ReactiveField 'default'
    @testOutfitId = new ReactiveField null
    @renderingSide = new ReactiveField LOI.Engine.RenderingSides.Keys.Front
    @direction = new ReactiveField null

    @avatars = []

    for url, index in avatarUrls
      @avatars.push
        avatar: new ReactiveField null

      do (url, index) =>
        HTTP.call 'GET', url, (error, result) =>
          if error
            console.error error
            return

          document = new LOI.NonPlayerCharacter EJSON.parse result.content

          avatar = new LOI.Character.Avatar document
          @avatars[index].avatar avatar

          renderObject = avatar.getRenderObject()
          #renderObject.position.x = Math.random() * 10 - 5
          #renderObject.position.z = Math.random() * 10 - 5
          renderObject.position.x = index
          renderObject.faceDirection LOI.Engine.RenderingSides.getDirectionForSide @renderingSide()
          @directionReferenceRenderObject ?= renderObject

          sceneManager = @sceneManager()
          sceneManager.scene().add renderObject
          sceneManager.addedSceneObjects()

          Tracker.autorun =>
            animationName = @testAnimationName()
            renderObject.setAnimation animationName

    # Reactively set outfits on avatars.
    @autorun (computation) =>
      if outfitTemplate = LOI.Character.Part.Template.documents.findOne @testOutfitId()
        outfit = node: outfitTemplate.latestVersion?.data or outfitTemplate.data

      for avatar in @avatars
        avatar.avatar()?.customOutfit outfit

    # Reactively face avatars.
    @autorun (computation) =>
      direction = LOI.Engine.RenderingSides.getDirectionForSide @renderingSide()

      for avatar in @avatars
        continue unless renderObject = avatar.avatar()?.getRenderObject()
        renderObject.faceDirection direction

  onRendered: ->
    super arguments...

    @display = @callAncestorWith 'display'

    # Do initial forced update and draw.
    @forceUpdateAndDraw()

    # Add the WebGL canvas directly to DOM.
    @$('.scene').append @rendererManager().renderer.domElement

  onDestroyed: ->
    super arguments...

    for avatar in @avatars
      continue unless av = avatar.avatar()
      av.destroy()

  viewingAngles: ->
    [
      LOI.Engine.RenderingSides.angles.front
      LOI.Engine.RenderingSides.angles.frontLeft
      LOI.Engine.RenderingSides.angles.left
      LOI.Engine.RenderingSides.angles.backLeft
      LOI.Engine.RenderingSides.angles.back
    ]

  forceUpdateAndDraw: ->
    appTime = Tracker.nonreactive => @app.appTime()
    @update appTime
    @draw appTime

  update: (appTime) ->
    for sceneItem in @sceneManager().scene().children when sceneItem instanceof AS.RenderObject
      sceneItem.update? appTime,
        camera: @rendererManager().camera

    currentAngle = @directionReferenceRenderObject?.currentAngle
    @direction LOI.Engine.RenderingSides.getDirectionForAngle currentAngle if currentAngle?

    @sceneManager().update appTime

  draw: (appTime) ->
    @rendererManager().draw appTime

  class @DirectionSelection extends AM.DataInputComponent
    @register 'LandsOfIllusions.Pages.Admin.Characters.AnimationsTest.DirectionSelection'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @animationsTest = @ancestorComponentOfType LOI.Pages.Admin.Characters.AnimationsTest

    options: ->
      for renderingSide, key of LOI.Engine.RenderingSides.Keys
        name: renderingSide
        value: key

    load: ->
      @animationsTest.renderingSide()

    save: (value) ->
      @animationsTest.renderingSide value

  class @AnimationSelection extends AM.DataInputComponent
    @register 'LandsOfIllusions.Pages.Admin.Characters.AnimationsTest.AnimationSelection'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @animationsTest = @ancestorComponentOfType LOI.Pages.Admin.Characters.AnimationsTest

    options: ->
      for animationName in ['default', 'Idle', 'Idle loop', 'Walk 50']
        name: animationName
        value: animationName

    load: ->
      @animationsTest.testAnimationName()

    save: (value) ->
      @animationsTest.testAnimationName value

  class @OutfitSelection extends AM.DataInputComponent
    @register 'LandsOfIllusions.Pages.Admin.Characters.AnimationsTest.OutfitSelection'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @animationsTest = @ancestorComponentOfType LOI.Pages.Admin.Characters.AnimationsTest

    options: ->
      outfits = LOI.Character.Part.Template.documents.fetch
        type: LOI.Character.Part.Types.Avatar.Outfit.options.type

      options = [
        name: ''
        value: ''
      ]

      for outfit in outfits
        options.push
          name: outfit.name.translate().text
          value: outfit._id

      options

    load: ->
      @animationsTest.testOutfitId()

    save: (value) ->
      @animationsTest.testOutfitId value
