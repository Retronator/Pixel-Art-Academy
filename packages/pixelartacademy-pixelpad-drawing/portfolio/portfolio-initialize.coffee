AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio extends PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio
  # We call register here because it is the last in the inheritance chain.
  @register @id()

  @ExternalSoftware =
    Aseprite: 'Aseprite'
    PyxelEdit: 'Pyxel Edit'
    GraphicsGale: 'GraphicsGale'
    ProMotion: 'Pro Motion'
    GrafX2: 'GrafX2'
    Photoshop: 'Photoshop'
    GIMP: 'GIMP'
    Krita: 'Krita'
    Pixaki: 'Pixaki'
    Dottable: 'Dottable'
    Pixly: 'Pixly'
    PixelArtStudio: 'Pixel Art Studio'
    
  onCreated: ->
    super arguments...

    sectionLocations =
      tutorial: new PAA.Practice.Tutorials.Drawing
      challenge: new PAA.Practice.Challenges.Drawing
      project: new PAA.Practice.Project.Workbench
    
    for sectionThingName, sectionLocation of sectionLocations
      do (sectionThingName, sectionLocation) =>
        sectionThings = new ComputedField =>
          # Get things from the section location. Note: we expect things to be instances, so
          # they have to be added as instances in the workbench scene, and not as classes.
          currentSituation = new LOI.Adventure.Situation
            location: sectionLocation
          
          currentSituation.things()
        ,
          (a, b) =>
            _.isArray(a) and _.isArray(b) and a.length is b.length and _.intersection(a, b).length is a.length
        
        groupsProvider = Tracker.nonreactive => new @constructor.GroupsProvider sectionThings, 0

        section =
          nameKey: @constructor.Sections["#{_.upperFirst sectionThingName}s"]
          groupsProvider: groupsProvider
          groups: groupsProvider.groups
          isSection: true

        @["#{sectionThingName}sSection"] = section
  
    # Create artwork assets.
    @_artworkAssets = {}
    @_artworkAssetsDependency = new Tracker.Dependency
  
    @_artworkIds = new ComputedField =>
      return [] unless artworks = PAA.PixelPad.Apps.Drawing.state 'artworks'
      artwork.artworkId for artwork in artworks
  
    @_artworksDictionary = new AE.ReactiveDictionary =>
      artworkIds = @_artworkIds()
      dictionary = {}
      
      PADB.Artwork.documents.find(_id: $in: artworkIds).forEach (artwork) =>
        dictionary[artwork._id] = dictionary
  
      dictionary
    ,
      added: (id) =>
        @_artworkAssets[id] = new PAA.PixelPad.Apps.Drawing.Portfolio.ArtworkAsset id
        @_artworkAssetsDependency.changed()
  
      removed: (id) =>
        @_artworkAssets[id].destroy()
        delete @_artworkAssets[id]
        @_artworkAssetsDependency.changed()
    
    # Create WIP artworks group.
    @_newArtworkAsset = new PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork
    @_importArtworkAsset = new PAA.PixelPad.Apps.Drawing.Portfolio.ImportArtwork

    @_wipArtworksGroup =
      level: 0
      index: 0
      name: => "Work in progress"
      assets: new ComputedField =>
        assets = []
        
        # Get all WIP artworks.
        @_artworkAssetsDependency.depend()
        
        artworkIds = @_artworkIds()
        
        wipArtworks = PADB.Artwork.documents.fetch
          _id: $in: artworkIds
          wip: true
        ,
          sort:
            startDate: 1
          
        for artwork, assetIndex in wipArtworks
          do (artwork, assetIndex) =>
            return unless asset = @_artworkAssets[artwork._id]
          
            assets.push @constructor.AssetData.getForAsset asset, assetIndex
  
        if PAA.PixelPad.Apps.Drawing.canCreateArtworks()
          assets.push @constructor.AssetData.getForAsset @_newArtworkAsset, assetIndex
  
          # TODO: Enable uploading of artworks.
          ###
          assets.push
            _id: @_importArtworkAsset.urlParameter()
            index: assets.length
            asset: @_importArtworkAsset
            scale: => 1
          ###
  
        assets
        
    @artworksSection =
      nameKey: @constructor.Sections.Artworks
      isSection: true
      groups: =>
        groups = []
  
        if @_wipArtworksGroup.assets().length
          groups.push @_wipArtworksGroup
          
        # TODO: Fetch all artworks.
    
        groups
  
    @sections = new ComputedField =>
      sections = []
  
      sections.push @tutorialsSection if @tutorialsSection.groups().length
      sections.push @challengesSection if @challengesSection.groups().length
      sections.push @projectsSection if @projectsSection.groups().length
      sections.push @artworksSection if @artworksSection.groups().length

      # If the active section is not present anymore, close the section.
      if @activeSection and not @activeSection() in sections
        @activeSection null
        @activeGroups []
        @hoveredAsset null
        @lastHoveredAsset null

      # Update section indices.
      section.index = index for section, index in sections

      sections

    @activeSection = new ReactiveField null, (a, b) => a is b
    @activeGroups = new ReactiveField [], _.arraysHaveSameValues

    # Clear stale active groups.
    @autorun (computation) =>
      return unless activeSection = @activeSection()
      return unless activeGroups = @activeGroups()
      
      refreshedActiveGroups = _.clone activeGroups
      groupsWereRefreshed = false
      
      newGroups = activeSection.groups()
      
      for activeGroup, activeGroupIndex in activeGroups
        currentGroups = newGroups
        newGroups = newGroups[activeGroup.index]?.groups?()
        continue if activeGroup in currentGroups
  
        # See if we can find a group with the same name.
        name = activeGroup.name()
        sameNamedGroup = _.find currentGroups, (group) => group.name() is name
  
        if sameNamedGroup
          # We found the same group so it must have just re-created.
          refreshedActiveGroups[activeGroupIndex] = sameNamedGroup
          groupsWereRefreshed = true
          continue
  
        # Seems like the active group is not valid anymore. Return to highest valid level.
        refreshedActiveGroups = refreshedActiveGroups[0...activeGroupIndex]
        groupsWereRefreshed = true
        break
        
      @activeGroups refreshedActiveGroups if groupsWereRefreshed

    @hoveredAsset = new ReactiveField null, (a, b) => a is b
    @lastHoveredAsset = new ReactiveField null, (a, b) => a is b
    @activeAsset = new ReactiveField null, (a, b) => a is b
    @waitingAsset = new ReactiveField null, (a, b) => a is b

    # Animate newly created assets.
    @_lastGroupAssets = null
    
    @autorun (computation) =>
      # Clear last assets when an assets group has changed.
      activeGroups = @activeGroups()
      group = _.last(activeGroups)
      assets = group?.assets?()

      unless assets
        @_lastGroupAssets = null
        return
        
      unless @_lastGroupAssets?.group is group
        @_lastGroupAssets =
          group: group
          assets: assets
      
      # See if a new asset was added.
      newAssets = _.difference assets, @_lastGroupAssets.assets
      @_lastGroupAssets.assets = assets
      return unless newAssets.length
      
      Meteor.clearTimeout @_revealTimeout
      @waitingAsset _.last newAssets
    
    @autorun (computation) =>
      return unless waitingAsset = @waitingAsset()
      
      if activeAsset = @activeAsset()
        # If the waiting asset became active, don't do the reveal.
        @waitingAsset null if activeAsset is waitingAsset
        
        # Wait until there's no active asset (we're not on the clipboard anymore).
        return
      
      # Reveal the asset after transitions.
      @_revealTimeout = Meteor.setTimeout =>
        @waitingAsset null
      ,
        750

    # Determine the active section, group, and asset based on the URL.
    @autorun (computation) =>
      unless urlParameter = AB.Router.getParameter 'parameter3'
        @activeAsset null
        return

      # Find the asset that uses this parameter.
      for section in @sections()
        for group in section.groups()
          if result = @_searchGroupForAssetWithUrlParameter group, urlParameter, [group]
            @activeSection section
            @activeGroups result.groups
            @activeAsset result.asset
            return

    # Displayed asset retains its value until another asset gets activated
    @displayedAsset = new ReactiveField null, (a, b) => a is b

    @autorun (computation) =>
      return unless activeAsset = @activeAsset()
      @displayedAsset activeAsset
    
    # Wire sounds on changes of sections and groups, but don't play two at once (group has priority).
    @autorun (computation) =>
      # Depend on section changes.
      section = @activeSection()
      
      return if @_updateGroupTimeout
      
      @_updateSectionTimeout = Meteor.setTimeout =>
        if section then @audio.sectionOpen() else @audio.sectionClose()
        @_updateSectionTimeout = null
      ,
        0
    
    # To isolate recreation of groups, we depend on group names.
    @lastActiveGroupName = new ComputedField =>
      _.last(@activeGroups())?.name()

    @autorun (computation) =>
      @lastActiveGroupName()
      
      lastActiveGroup = Tracker.nonreactive => _.last @activeGroups()
      
      Meteor.clearTimeout @_updateSectionTimeout
      
      @_updateGroupTimeout = Meteor.setTimeout =>
        if lastActiveGroup then @audio.groupOpen() else @audio.groupClose()
        @_updateGroupTimeout = null
      ,
        0
  
    @assetGroupIsActive = new ComputedField =>
      return false unless activeGroups = @activeGroups()
      _.last(activeGroups)?.assets
      
    @visibleGroupsCount = new ComputedField =>
      return 0 unless activeSection = @activeSection()
      
      count = activeSection.groups().length
      
      return count unless activeGroups = @activeGroups()
      
      for group in activeGroups when group.groups
        count += group.groups().length
      
      count
    
    @lastActiveGroupGroupsCount = new ComputedField =>
      return 0 unless activeSection = @activeSection()
      activeGroups = @activeGroups()
      
      if activeGroups.length
        _.last(activeGroups).groups?().length or 0
        
      else
        activeSection.groups().length
        
    @minimizableGroupsCount = new ComputedField =>
      @visibleGroupsCount() - @lastActiveGroupGroupsCount()
      
    @minimalGroupsHeight = new ComputedField =>
      return 0 unless activeGroups = @activeGroups()
      activeGroups.length * @maxInitialGroupHeight
      
    @minimizableGroupHeight = new ComputedField =>
      minimizableHeightSpace = @groupsMaxTotalHeight - @minimalGroupsHeight() - @maxInitialGroupHeight * @lastActiveGroupGroupsCount()
      heightPerGroup = Math.floor minimizableHeightSpace / @minimizableGroupsCount()
      Math.min heightPerGroup, @maxInitialGroupHeight
    
    @minimizedGroupHeight = new ComputedField =>
      minimizedHeightSpace = @groupsMaxTotalHeight - @activeGroupHeight - @minimalGroupsHeight()
      heightPerGroup = Math.floor minimizedHeightSpace / (@visibleGroupsCount() - 1)
      _.clamp heightPerGroup, @minMinimizedGroupHeight, @maxMinimizedGroupHeight
    
    @initialGroupHeight = new ComputedField =>
      return @maxInitialGroupHeight unless lastActiveGroupGroupsCount = @lastActiveGroupGroupsCount()
      initialHeightSpace = @groupsMaxTotalHeight - @minimalGroupsHeight() - @minimizedGroupHeight() * @minimizableGroupsCount()
      heightPerGroup = Math.floor initialHeightSpace / lastActiveGroupGroupsCount
      Math.min heightPerGroup, @maxInitialGroupHeight
    
    @inactiveGroupHeight = new ComputedField =>
      if @assetGroupIsActive() then @minimizedGroupHeight() else @minimizableGroupHeight()
      
    @activeGroupHeaderHeight = new ComputedField =>
      if @assetGroupIsActive() then @reducedGroupHeight else @maxInitialGroupHeight
      
    @activeSectionHeight = new ComputedField =>
      return 0 unless activeSection = @activeSection()
      groups = activeSection.groups()
      activeGroups = @activeGroups()
      
      if activeGroups.length
        height = @sectionHeight + (groups.length - 1) * @inactiveGroupHeight() + @groupHeight activeGroups[0], activeGroups
      
      else
        height = @sectionHeight + groups.length * @initialGroupHeight()
      
    @inactiveSectionHeight = new ComputedField =>
      return @sectionHeight unless @activeSection()
      
      sections = @sections()
      
      activeSectionHeight = @activeSectionHeight()
      sectionsTotalHeight = (sections.length - 1) * @sectionHeight + activeSectionHeight
      
      if sectionsTotalHeight > @sectionsMaxTotalHeight
        # We need to decrease inactive section heights to make them all fit into maximum total height.
        heightForInactiveSections = @sectionsMaxTotalHeight - activeSectionHeight
        heightForInactiveSections / (sections.length - 1)
        
      else
        @sectionHeight
        
  onRendered: ->
    super arguments...
    
    # Allow cheating with the function keys.
    $(document).on 'keydown.pixelartacademy-pixelpad-apps-drawing-portfolio', (event) => @onKeyDown event
  
  onDestroyed: ->
    super arguments...
    
    $(document).off '.pixelartacademy-pixelpad-apps-drawing-portfolio'
    
    @_artworksDictionary.stop()
    @_newArtworkAsset.destroy()
    @_importArtworkAsset.destroy()
  
    @tutorialsSection.groupsProvider.destroy()
    @challengesSection.groupsProvider.destroy()
    @projectsSection.groupsProvider.destroy()
    @constructor.AssetData.destroy()
  
  _searchGroupForAssetWithUrlParameter: (group, urlParameter, currentGroups) ->
    if group.assets
      for assetData in group.assets()
        if assetData.asset.urlParameter() is urlParameter
          return {
            groups: currentGroups
            asset: assetData
          }
      
    if group.groups
      for group in group.groups()
        if result = @_searchGroupForAssetWithUrlParameter group, urlParameter, [currentGroups..., group]
          return result
      
    null
