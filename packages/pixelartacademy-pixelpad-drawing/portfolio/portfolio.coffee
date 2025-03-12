AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
AEc = Artificial.Echo
AC = Artificial.Control
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class PAA.PixelPad.Apps.Drawing.Portfolio extends LOI.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio'
  
  @Sections:
    Tutorials: 'Tutorials'
    Challenges: 'Challenges'
    Projects: 'Projects'
    Artworks: 'Artworks'
    Settings: 'Settings'

  # Subscriptions
  @artworksWithAssets = new AB.Subscription name: "#{@id()}.artworks"
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      sectionOpen: AEc.ValueTypes.Trigger
      sectionClose: AEc.ValueTypes.Trigger
      sectionHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      groupOpen: AEc.ValueTypes.Trigger
      groupClose: AEc.ValueTypes.Trigger
      groupHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      assetHover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 100
      assetPan:
        valueType: AEc.ValueTypes.Number
        
  constructor: (@drawing) ->
    super arguments...

    @sectionHeight = 25
    @initialGroupHeight = 19
    @inactiveGroupHeight = 5
    @activeGroupHeight = 150
    @settingsHeight = 118
    @sectionsMargin = 13
    @sectionsMaxTotalHeight = 241 - 2 * @sectionsMargin

  sectionActiveClass: ->
    section = @currentData()

    'active' if @activeSection() is section

  groupInSectionActiveClass: ->
    section = @currentData()

    'group-in-section-active' if @activeSection() is section and @activeGroup()

  sectionStyle: ->
    section = @currentData()
    groups = section.groups()
    
    activeSection = @activeSection()
    activeGroup = @activeGroup()
    
    width = @sectionWidth section
    
    if section is activeSection
      if activeGroup
        activeSectionHeight = @sectionHeight + (groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight
      
      else
        activeSectionHeight = @sectionHeight + groups.length * @initialGroupHeight
        
      height = activeSectionHeight
      
    else
      height = @inactiveSectionHeight()
      
    style =
      width: "#{width}rem"
      height: "#{height}rem"
    
    style
    
  sectionWidth: (section) ->
    292 - 4 * (@sections().length - section.index)

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'groups'
    
    sectionWidth = @sectionWidth section

    width: "#{sectionWidth - 18 - 3 * (section.groups().length - group.index - 1)}rem"

  groupActiveClass: ->
    group = @currentData()

    'active' if @activeGroup() is group

  briefStyle: ->
    assetData = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - assetData.index

    zIndex: zIndex

  assetStyle: ->
    assetData = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - assetData.index

    zIndex: zIndex
    width: "#{assetData.asset.width() * assetData.scale() + assetData.asset.portfolioBorderWidth() * 2}rem"

  _assetScale: (asset) ->
    maxSize = 70
    size = Math.max asset.width(), asset.height()
    displayScale = LOI.adventure.interface.display.scale()

    unless asset.pixelArtScaling()
      # Without pixel art scaling, make the image fit into the 70px.
      maxWindowPixelSize = 70 * displayScale
      displaySize = Math.min size, maxWindowPixelSize
      return displaySize / size / displayScale
    
    # with pixel art scaling, scale the image as much as possible (up to 6) while remaining under 70px.
    return 1 if _.isNaN size
    
    scale = 1

    if size > maxSize
      # The asset is bigger than our maximum size, so we will need to scale downwards. We start
      # operating in effective scale to still have integer magnification compared to window pixels.
      maxEffectiveSize = maxSize * displayScale
      
      effectiveScale = displayScale
      effectiveScale-- while size * effectiveScale > maxEffectiveSize
    
      return effectiveScale / displayScale if effectiveScale > 0
      
      # We need to reduce scale below 1 effective pixel so we start dividing by integer amounts below 1.
      divisor = 1
      divisor++ while size / divisor > maxEffectiveSize
      
      effectiveScale = 1 / divisor
      return effectiveScale / displayScale

    scale++ while scale < 6 and (scale + 1) * size < maxSize

    scale

  coverStyle: ->
    sections = @sections()
    
    sectionsCount = sections.length
    sectionsCount++ if @showSettingsSection()
    
    inactiveSectionHeight = @inactiveSectionHeight()

    if section = @activeSection()
      top = @sectionsMargin + (sectionsCount - 1) * inactiveSectionHeight + @sectionHeight
  
      if groups = section.groups?()
        if @activeGroup()
          top += (groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

        else
          top += groups.length * @initialGroupHeight

      else
        top += @settingsHeight
        
    else
      top = @sectionsMargin + sectionsCount * inactiveSectionHeight

    top: "#{top}rem"
  
  sectionsVisible: ->
    # Only show sections when not in the editor to prevent updates while editing.
    not @drawing.editor().active()

  assetHoveredClass: ->
    assetData = @currentData()

    'hovered' if assetData is @hoveredAsset()
    
  assetLastHoveredClass: ->
    assetData = @currentData()
    
    'last-hovered' if assetData is @lastHoveredAsset()

  assetActiveClass: ->
    assetData = @currentData()

    'active' if assetData is @activeAsset()

  showSettingsSection: ->
    # Only potentially hide settings in Learn Mode.
    return true unless AB.Router.currentRouteName() is LM.Adventure.id()
    
    # Only show settings if there is more than one choice (besides the None option).
    @editors().length > 2

  selectedEditorClass: ->
    editor = @currentData()
    selectedEditorId = @drawing.state('editorId') or null

    'selected' if selectedEditorId is editor.id()

  selectedSoftwareClass: ->
    software = @currentData()
    selectedSoftware = @drawing.state('externalSoftware') or null

    'selected' if selectedSoftware is software.value

  events: ->
    super(arguments...).concat
      'click .section': @onClickSection
      'click .group-header': @onClickGroupHeader
      'click': @onClick
      'mouseenter .section': @onMouseEnterSection
      'mouseenter .group-name': @onMouseEnterGroupName
      'mouseenter .asset': @onMouseEnterAsset
      'mouseleave .asset': @onMouseLeaveAsset
      'click .brief': @onClickBrief
      'click .asset': @onClickAsset
      'click .pixel-boy .editor': @onClickPixelPadEditor
      'click .external .editor': @onClickExternalEditor

  onClickSection: (event) ->
    section = @currentData()

    clickInsideContent = $(event.target).closest('.content').length > 0

    if section is @activeSection()
      @activeSection null unless clickInsideContent

    else
      @activeSection section

      # Reset group if we click on the name, but not one of the inner groups.
      # In that case the group handler will activate a new group in this new section.
      @activeGroup null unless clickInsideContent

  onClickGroupHeader: (event) ->
    group = @currentData()
    section = @parentDataWith 'groups'
    
    # Only open the group if we have an active section or if the group is the only one in the section.
    return unless @activeSection() is section or section.groups().length is 1

    if group is @activeGroup()
      @activeGroup null

    else
      @activeGroup group

  onClick: (event) ->
    # If we click outside the clipboard, close current asset.
    if @activeAsset() and not $(event.target).closest('.clipboard').length
      @activeAsset null
      return

    # If we click outside a group, close current group.
    if @activeGroup() and not $(event.target).closest('.group').length
      @activeGroup null

      # Don't let section close as well, if we were clicking inside the current section.
      event.stopPropagation() if @currentData() is @activeSection()
      return

    # If we click outside a section, close current section.
    @activeSection null if @activeSection() and not $(event.target).closest('.section').length
  
  onMouseEnterSection: (event) ->
    section = @currentData()
    return if section is @activeSection()
    
    @audio.sectionHover()
    
  onMouseEnterGroupName: (event) ->
    group = @currentData()
    return if group is @activeGroup()
    
    return unless activeSection = @activeSection()
    
    section = @parentDataWith 'groups'
    return unless section is activeSection
    
    @audio.groupHover()

  onMouseEnterAsset: (event) ->
    assetData = @currentData()
    @hoveredAsset assetData
    @lastHoveredAsset assetData
    
    @audio.assetPan AEc.getPanForElement event.target
    @_assetHoverUnlessFirst assetData

  onMouseLeaveAsset: (event) ->
    assetData = @hoveredAsset()
    @hoveredAsset null

    # Only trigger the hover sound when we're not leaving because of selecting an asset.
    @_assetHoverUnlessFirst assetData if assetData and not @activeAsset()
    
  _assetHoverUnlessFirst: (assetData) ->
    return unless assetData.index
    
    @audio.assetHover()

  onClickBrief: (event) ->
    @_goToClickedAsset()

  onClickAsset: (event) ->
    @_goToClickedAsset()

  _goToClickedAsset: ->
    assetData = @currentData()

    # Set active sprite ID.
    AB.Router.changeParameter 'parameter3', assetData.asset.urlParameter()

  onClickPixelPadEditor: (event) ->
    editor = @currentData()
    @drawing.state 'editorId', editor.id()

  onClickExternalEditor: (event) ->
    program = @currentData()
    @drawing.state 'externalSoftware', program.value
  
  onKeyDown: (event) ->
    # To get into cheating mode, you have to have shift pressed (and alt released),
    # to prevent accidental cheating when quitting on windows with alf-F4.
    if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f2, shift: true}
      return unless asset = @activeAsset()?.asset
      
      return unless stepArea = asset.stepAreas?()[0]
      activeStep = stepArea.steps()[stepArea.activeStepIndex()]
      
      activeStep.solve()
      event.preventDefault()
      
    else if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f3, shift: true}
      return unless asset = @activeAsset()?.asset
      
      asset.solveAndComplete?()
      event.preventDefault()
    
    else if AC.Keyboard.isShortcutDown event, {key: AC.Keys.f4, shift: true}
      console.log "Cheating commences …"
      
      return unless activeGroup = @activeGroup()
      return unless activeGroup.thing.assets() and activeGroup.thing.state 'assets'
      
      cheating = =>
        assets = activeGroup.thing.assets()
        assetsData = activeGroup.thing.state 'assets'
        
        cheatMore = false
        
        while uncompletedAssetData = _.find assetsData, (assetData) -> not assetData.completed
          console.log "Completing", uncompletedAssetData.id
          
          uncompletedAsset = _.find assets, (asset) -> asset.id() is uncompletedAssetData.id
          uncompletedAsset.solve()
          uncompletedAssetData.completed = true
          
          cheatMore = true
        
        if cheatMore
          activeGroup.thing.state 'assets', assetsData
          Meteor.setTimeout cheating, 100
        
        else
          console.log "Cheating commenced!"
      
      cheating()
      
      event.preventDefault()
