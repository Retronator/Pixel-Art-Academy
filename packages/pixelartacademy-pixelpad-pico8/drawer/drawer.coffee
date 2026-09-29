AB = Artificial.Base
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Pico8.Drawer extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Pico8.Drawer'
  @register @id()
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      drawerOpen: AEc.ValueTypes.Trigger
      caseOpen: AEc.ValueTypes.Trigger
      caseClose: AEc.ValueTypes.Trigger
      cartridgeSelect: AEc.ValueTypes.Trigger
      
  constructor: (@pico8) ->
    super arguments...

    @opened = new ReactiveField false
    @pannedLeft = new ReactiveField false
    @selectedCartridge = new ReactiveField null
    @selectedCartridgeVariant = new ReactiveField null
    @selectedCartridgeVariantIndex = new ReactiveField null

  onCreated: ->
    super arguments...

    # Create a random ID to prevent caching carts. We assume the art won't
    # change while in the app, to prevent constant calls to the server.
    @_runId = Random.id()

    @cartridgesLocation = new PAA.Pico8.Cartridges

    @cartridgesSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @cartridgesLocation

      return unless options.timelineId

      new LOI.Adventure.Situation options

    # We use a cache to avoid reconstruction.
    @_defaultCartridges = {}
    @_projectCartridges = {}

    @cartridges = new ComputedField =>
      return unless cartridgesSituation = @cartridgesSituation()

      cartridgeClasses = cartridgesSituation.things()

      for cartridgeClass in cartridgeClasses
        projectClass = cartridgeClass.projectClass()
        projects = projectClass.getProjects()
        activeProjectId = projectClass.state 'activeProjectId'
        activeCartridgeVariant = null
        cartridgeVariants = []

        if projects.length
          for project in projects
            @_projectCartridges[project._id] ?= Tracker.nonreactive =>
              variant = new cartridgeClass projectId: project._id

              # Override the thing ID with the project ID for Blaze reactivity.
              variant._id = project._id
              variant
            
            cartridgeVariant =
              cartridge: @_projectCartridges[project._id]
              
            if project._id is activeProjectId
              activeCartridgeVariant = cartridgeVariant
              
            else
              cartridgeVariants.push cartridgeVariant
              
          cartridgeVariants.push activeCartridgeVariant if activeCartridgeVariant

        else
          @_defaultCartridges[cartridgeClass.id()] ?= Tracker.nonreactive => new cartridgeClass
          cartridgeVariants.push cartridge: @_defaultCartridges[cartridgeClass.id()]
        
        cartridgeVariant.index = index for cartridgeVariant, index in cartridgeVariants
        
        class: cartridgeClass
        variants: cartridgeVariants
        
    # Select cartridge based on URL parameter.
    @autorun (computation) =>
      if gameSlugOrProjectId = AB.Router.getParameter 'parameter3'
        cartridges = @cartridges()
        
        for cartridge in cartridges
          if cartridge.class.gameSlug() is gameSlugOrProjectId
            @selectedCartridge cartridge
            @selectedCartridgeVariant cartridge.variants[0]
            @selectedCartridgeVariantIndex 0
            return
            
          for variant in cartridge.variants
            if variant.cartridge.options.projectId is gameSlugOrProjectId
              @selectedCartridge cartridge
              @selectedCartridgeVariant variant
              @selectedCartridgeVariantIndex cartridge.variants.indexOf variant
              return
      
      else
        @audio.caseClose() if Tracker.nonreactive => @selectedCartridge()

      @selectedCartridge null
      @selectedCartridgeVariant null
      @selectedCartridgeVariantIndex null

  onRendered: ->
    super arguments...

    # Open the drawer on app launch.
    Meteor.setTimeout =>
      @opened true
      @audio.drawerOpen()
    ,
      500

  onDestroyed: ->
    super arguments...

    cartridge.destroy() for gameSlug, cartridge of @_cartridges

  deselectCartridge: ->
    AB.Router.changeParameter 'parameter3', null
    @pannedLeft false

  openedClass: ->
    'opened' if @opened()

  coveredClass: ->
    'covered' if @pico8.cartridge()
    
  selectedClass: ->
    cartridge = @currentData()
    
    'selected' if cartridge is @selectedCartridge()
  
  caseClass: ->
    cartridgeVariant = @currentData()
    cartridges = @parentData()
    
    'darker' unless (cartridges.variants.length - cartridgeVariant.index) % 2
    
  caseStyle: ->
    cartridgeVariant = @currentData()
    
    left: "#{-cartridgeVariant.index}rem"
    top: "#{-cartridgeVariant.index}rem"
    zIndex: cartridgeVariant.index + 1
  
  cartridgeImageUrl: ->
    cartridgeVariant = @currentData()
    
    return unless url = cartridgeVariant.cartridge.imageUrl()
    
    # Don't cache local carts.
    if url.indexOf('pico8/cartridge.png') > 0
      url += "&runId=#{@_runId}"
    
    url
    
  shadowStyle: ->
    cartridgeVariant = @currentData()
    
    left: "#{-3 * (1 + cartridgeVariant.index)}rem"
    top: "#{1 + Math.floor cartridgeVariant.index / 3}rem"

  activeClass: ->
    'active' if @selectedCartridge()

  pannedLeftClass: ->
    'panned-left' if @pannedLeft()

  showPreviousVariant: ->
    @selectedCartridgeVariantIndex()
    
  showNextVariant: ->
    return unless selectedCartridge = @selectedCartridge()
    @selectedCartridgeVariantIndex() < selectedCartridge.variants.length - 1

  cartridgeShareUrl: ->
    cartridge = @currentData()
    cartridge.shareUrl()

  events: ->
    super(arguments...).concat
      'click': @onClick
      'click .cartridge': @onClickCartridge
      'click .previous.variant-button': @onClickPreviousVariantButton
      'click .next.variant-button': @onClickNextVariantButton
      'click .selected-cartridge .memory-card': @onClickSelectedCartridgeMemoryCard
      'click .selected-cartridge .case-top': @onClickSelectedCartridgeCaseTop
      'click .selected-cartridge .case-bottom': @onClickSelectedCartridgeCaseBottom

  onClick: (event) ->
    return unless @selectedCartridge()

    $target = $(event.target)
    return if $target.closest('.selected-cartridge').length

    @deselectCartridge()

  onClickCartridge: (event) ->
    cartridge = @currentData()
    topVariant = _.last cartridge.variants
    
    if projectId = topVariant.cartridge.options.projectId
      AB.Router.changeParameter 'parameter3', projectId
    
    else
      AB.Router.changeParameter 'parameter3', cartridge.class.gameSlug()
    
    @audio.caseOpen()
  
  onClickPreviousVariantButton: (event) ->
    previousVariantIndex = @selectedCartridgeVariantIndex() - 1
    previousVariant = @selectedCartridge().variants[previousVariantIndex]

    AB.Router.changeParameter 'parameter3', previousVariant.cartridge.options.projectId

  onClickNextVariantButton: (event) ->
    nextVariantIndex = @selectedCartridgeVariantIndex() + 1
    nextVariant = @selectedCartridge().variants[nextVariantIndex]

    AB.Router.changeParameter 'parameter3', nextVariant.cartridge.options.projectId

  onClickSelectedCartridgeMemoryCard: (event) ->
    if @pannedLeft()
      @pannedLeft false
      return
      
    AB.Router.changeParameter 'parameter4', 'play'
    
    @audio.cartridgeSelect()
  
  onClickSelectedCartridgeCaseTop: (event) ->
    # TODO: Show case top only for online projects.
    # @pannedLeft true

  onClickSelectedCartridgeCaseBottom: (event) ->
    @pannedLeft false
