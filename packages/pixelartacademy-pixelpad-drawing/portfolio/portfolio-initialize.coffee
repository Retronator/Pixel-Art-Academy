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

    profileId = LOI.adventure.profileId()

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
        
        groups = new ComputedField =>
          for sectionThing, index in sectionThings()
            do (sectionThing, index) =>
              assets = new ComputedField =>
                for asset, assetIndex in sectionThing.assets() when asset.urlParameter()
                  do (asset, assetIndex) =>
                    _id: asset.urlParameter()
                    index: assetIndex
                    asset: asset
                    scale: => @_assetScale asset

              thing: sectionThing
              index: index
              name: => sectionThing.fullName()
              noAssetsInstructions: => sectionThing.noAssetsInstructions?()
              assets: assets
              content: => sectionThing.content?()

        section =
          nameKey: @constructor.Sections["#{_.upperFirst sectionThingName}s"]
          groups: groups

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
          
            assets.push
              _id: asset.urlParameter()
              index: assetIndex
              asset: asset
              scale: => @_assetScale asset
  
        if PAA.PixelPad.Apps.Drawing.canCreateArtworks()
          assets.push
            _id: @_newArtworkAsset.urlParameter()
            index: assets.length
            asset: @_newArtworkAsset
            scale: => 1
  
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
        @activeGroup null
        @hoveredAsset null
        @lastHoveredAsset null

      # Update section indices.
      section.index = index for section, index in sections

      sections

    @settingsSection =
      nameKey: @constructor.Sections.Settings

    @autorun (computation) =>
      sections = @sections()
      @settingsSection.index = sections.length

    @activeSection = new ReactiveField null, (a, b) => a is b
    @activeGroup = new ReactiveField null, (a, b) => a is b

    # Clear stale active groups.
    @autorun (computation) =>
      return unless activeSection = @activeSection()
      return unless activeGroup = @activeGroup()
      newGroups = activeSection.groups()
      return if activeGroup in newGroups

      # See if we can find a group with the same name.
      name = activeGroup.name()
      sameNamedGroup = _.find newGroups, (group) => group.name() is name

      if sameNamedGroup
        # We found the same group so it must have just re-created.
        @activeGroup sameNamedGroup
        return

      # Seems like the active group is not valid anymore.
      @activeGroup null

    @hoveredAsset = new ReactiveField null, (a, b) => a is b
    @lastHoveredAsset = new ReactiveField null, (a, b) => a is b
    @activeAsset = new ComputedField =>
      return unless parameter = AB.Router.getParameter 'parameter3'

      # Find the asset that uses this parameter.
      for section in @sections()
        for group in section.groups()
          for assetData in group.assets()
            if assetData.asset.urlParameter() is parameter
              @activeSection section
              @activeGroup group
              return assetData

    # Displayed asset retains its value until another asset gets activated
    @displayedAsset = new ReactiveField null, (a, b) => a is b

    @autorun (computation) =>
      return unless activeAsset = @activeAsset()
      @displayedAsset activeAsset

    # Prepare settings.
    editors = new PAA.PixelPad.Apps.Drawing.Editors
    
    currentEditorsSituation = new LOI.Adventure.Situation
      location: editors

    @_editors = {}

    @editors = new ComputedField =>
      editorClasses = currentEditorsSituation.things()
      editors = []

      for editorClass in editorClasses
        @_editors[editorClass.id()] ?= new editorClass
        editors.push @_editors[editorClass.id()]

      if editors.length
        editors.unshift
          id: => null
          fullName: 'None'

      editors
      
    @externalSoftware = ({value, fullName} for value, fullName of @constructor.ExternalSoftware)
    @externalSoftware = _.sortBy @externalSoftware, 'fullName'

    @externalSoftware.unshift
      value: null
      fullName: 'None'
  
    @externalSoftware.push
      value: 'other'
      fullName: 'Other software'
      
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
    @activeGroupName = new ComputedField =>
      @activeGroup()?.name()

    @autorun (computation) =>
      @activeGroupName()
      
      group = Tracker.nonreactive => @activeGroup()
      
      Meteor.clearTimeout @_updateSectionTimeout
      
      @_updateGroupTimeout = Meteor.setTimeout =>
        if group then @audio.groupOpen() else @audio.groupClose()
        @_updateGroupTimeout = null
      ,
        0
      
    @inactiveSectionHeight = new ComputedField =>
      return @sectionHeight unless activeSection = @activeSection()
      
      sections = @sections()
      activeSectionGroups = activeSection.groups()

      if @activeGroup()
        activeSectionHeight = @sectionHeight + (activeSectionGroups.length - 1) * @getInactiveGroupHeight(activeSectionGroups.length) + @activeGroupHeight
        
      else
        activeSectionHeight = @sectionHeight + activeSectionGroups.length * @getInitialGroupHeight activeSectionGroups.length
      
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
    
    editor.destroy?() for editor in @_editors
  
    @_artworksDictionary.stop()
    @_newArtworkAsset.destroy()
    @_importArtworkAsset.destroy()
