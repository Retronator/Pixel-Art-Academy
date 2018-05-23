AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio'
  
  @Sections:
    Projects: 'Projects'
    Artworks: 'Artworks'

  constructor: (@drawing) ->
    super

    @sectionHeight = 21
    @initialGroupHeight = 17
    @inactiveGroupHeight = 3
    @activeGroupHeight = 150

  onCreated: ->
    super

    @workbenchLocation = new PAA.Practice.Project.Workbench

    @currentProjects = new ComputedField =>
      new LOI.Adventure.Situation
        location: @workbenchLocation
        timelineId: LOI.adventure.currentTimelineId()

    @sections = new ComputedField =>
      # Get projects from the workbench. Note: we expect things to be instances, so
      # they have to be added as instances in the workbench scene, and not as classes.
      projects = @currentProjects().things()

      projectGroups = for project, index in projects
        assets = for asset, assetIndex in project.assets()
          asset: asset
          index: assetIndex

        index: index
        name: project.fullName()
        project: project
        assets: assets

      projectsSection =
        index: 0
        nameKey: @constructor.Sections.Projects
        groups: projectGroups

      artworksSection =
        index: 1
        nameKey: @constructor.Sections.Artworks
        groups: []

      [projectsSection, artworksSection]

    @activeSection = new ReactiveField null, (a, b) => a is b
    @activeGroup = new ReactiveField null, (a, b) => a is b
    @hoveredAsset = new ReactiveField null, (a, b) => a is b

    @activeAsset = new ComputedField =>
      return unless spriteId = AB.Router.getParameter 'parameter3'

      # Find the asset that uses this sprite.
      for section in @sections()
        for group in section.groups
          for assetData in group.assets
            if assetData.asset.spriteId() is spriteId
              @activeSection section
              @activeGroup group
              return assetData

    # Displayed asset retains its value until another asset gets activated
    @displayedAsset = new ReactiveField null

    @autorun (computation) =>
      return unless activeAsset = @activeAsset()
      @displayedAsset activeAsset

    # Subscribe to character's projects.
    PAA.Practice.Project.forCharacterId.subscribe @, LOI.characterId()

  sectionActiveClass: ->
    section = @currentData()

    'active' if @activeSection() is section

  groupInSectionActiveClass: ->
    section = @currentData()

    'group-in-section-active' if  @activeSection() is section and @activeGroup()

  sectionStyle: ->
    section = @currentData()
    active = @activeSection() is section

    width = 292 - 4 * (1 - section.index)

    style =
      width: "#{width}rem"

    if active
      if @activeGroup()
        height = @sectionHeight + (section.groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        height = @sectionHeight + section.groups.length * @initialGroupHeight

      style.height = "#{height}rem"

    style

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'groups'

    width: "#{270 - 3 * (section.groups.length - group.index - 1)}rem"

  groupActiveClass: ->
    group = @currentData()

    'active' if @activeGroup() is group

  briefStyle: ->
    asset = @currentData()
    project = @parentDataWith 'assets'

    zIndex = project.assets.length - asset.index

    zIndex: zIndex

  assetStyle: ->
    assetData = @currentData()
    project = @parentDataWith 'assets'
    zoom = @_assetZoom assetData.asset

    zIndex = project.assets.length - assetData.index

    zIndex: zIndex
    width: "#{assetData.asset.width() * zoom + 12}rem"

  spriteStyle: ->
    assetData = @currentData()
    zoom = @_assetZoom assetData.asset

    width: "#{assetData.asset.width() * zoom}rem"
    height: "#{assetData.asset.height() * zoom}rem"

  _assetZoom: (asset) ->
    # Zoom the sprite as much as possible while remaining under 88px.
    zoom = 1
    maxSize = Math.max asset.width(), asset.height()

    zoom++ while zoom < 7 and (zoom + 1) * maxSize < 88

    zoom

  spriteImage: ->
    assetData = @currentData()
    return unless spriteId = assetData.asset.spriteId()

    new LOI.Assets.Components.SpriteImage
      spriteId: => spriteId
      loadPalette: true

  coverStyle: ->
    top = 56

    if section = @activeSection()
      if @activeGroup()
        top += (section.groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        top += section.groups.length * @initialGroupHeight

    top: "#{top}rem"

  assetHoveredClass: ->
    assetData = @currentData()

    'hovered' if assetData is @hoveredAsset()

  assetActiveClass: ->
    assetData = @currentData()

    'active' if assetData is @activeAsset()

  events: ->
    super.concat
      'click .section': @onClickSection
      'click .group': @onClickGroup
      'click': @onClick
      'mouseenter .asset': @onMouseEnterAsset
      'mouseleave .asset': @onMouseLeaveAsset
      'click .asset': @onClickAsset

  onClickSection: (event) ->
    section = @currentData()
    return if section is @activeSection()

    @activeSection section

    # Reset group if we click on the name, but not one of the inner groups.
    # In that case the group handler will activate a new group in this new section.
    @activeGroup null unless $(event.target).closest('.group').length

  onClickGroup: (event) ->
    group = @currentData()
    @activeGroup group

  onClick: (event) ->
    # If we click outside the clipboard, close current asset.
    if @activeAsset() and not $(event.target).closest('.clipboard').length
      @activeAsset null
      return

    # If we click outside a group, close current group.
    if @activeGroup() and not $(event.target).closest('.group').length
      @activeGroup null
      return

    # If we click outside a section, close current section.
    @activeSection null if @activeSection() and not $(event.target).closest('.section').length

  onMouseEnterAsset: (event) ->
    assetData = @currentData()
    @hoveredAsset assetData

  onMouseLeaveAsset: (event) ->
    @hoveredAsset null

  onClickAsset: (event) ->
    assetData = @currentData()

    # Set active sprite ID.
    AB.Router.setParameter 'parameter3', assetData.asset.spriteId()
