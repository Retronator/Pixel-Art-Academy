AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio'
  
  @Sections:
    Challenges: 'Challenges'
    Projects: 'Projects'
    Artworks: 'Artworks'

  sectionActiveClass: ->
    section = @currentData()

    'active' if @activeSection() is section

  groupInSectionActiveClass: ->
    section = @currentData()

    'group-in-section-active' if  @activeSection() is section and @activeGroup()

  sectionStyle: ->
    section = @currentData()
    groups = section.groups()
    active = @activeSection() is section

    width = 292 - 4 * (1 - section.index)

    style =
      width: "#{width}rem"

    if active
      if @activeGroup()
        height = @sectionHeight + (groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        height = @sectionHeight + groups.length * @initialGroupHeight

      style.height = "#{height}rem"

    style

  groupStyle: ->
    group = @currentData()
    section = @parentDataWith 'groups'

    width: "#{270 - 3 * (section.groups().length - group.index - 1)}rem"

  groupActiveClass: ->
    group = @currentData()

    'active' if @activeGroup() is group

  briefStyle: ->
    asset = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - asset.index

    zIndex: zIndex

  assetStyle: ->
    assetData = @currentData()
    group = @parentDataWith 'assets'

    zIndex = group.assets().length - assetData.index

    zIndex: zIndex
    width: "#{assetData.asset.width() *  assetData.scale() + 12}rem"

  spriteStyle: ->
    assetData = @currentData()
    scale = assetData.scale()

    width: "#{assetData.asset.width() * scale}rem"
    height: "#{assetData.asset.height() * scale}rem"

  _assetScale: (asset) ->
    # Scale the sprite as much as possible (up to 8) while remaining under 88px.
    scale = 1
    maxSize = Math.max asset.width(), asset.height()

    scale++ while scale < 7 and (scale + 1) * maxSize < 88

    scale

  spriteImage: ->
    assetData = @currentData()
    return unless spriteId = assetData.asset.spriteId()

    new LOI.Assets.Components.SpriteImage
      spriteId: => spriteId
      loadPalette: true

  coverStyle: ->
    sections = @sections()

    top = 14 + sections.length * @sectionHeight

    if section = @activeSection()
      groups = section.groups()

      if @activeGroup()
        top += (groups.length - 1) * @inactiveGroupHeight + @activeGroupHeight

      else
        top += groups.length * @initialGroupHeight

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
