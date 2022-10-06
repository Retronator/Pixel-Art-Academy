AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Portfolio extends PixelArtAcademy.PixelBoy.Apps.Drawing.Portfolio
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

    characterId = LOI.characterId()

    sectionLocations =
      challenge: new PAA.Practice.Challenges.Drawing
      project: new PAA.Practice.Project.Workbench
    
    for sectionThingName, sectionLocation of sectionLocations
      do (sectionThingName, sectionLocation) =>
        groups = new ComputedField =>
          # Get groups from the section location. Note: we expect things to be instances, so
          # they have to be added as instances in the workbench scene, and not as classes.
          currentSituation = new LOI.Adventure.Situation
            location: sectionLocation

          sectionThings = currentSituation.things()

          for sectionThing, index in sectionThings
            do (sectionThing, index) =>
              assets = new ComputedField =>
                for asset, assetIndex in sectionThing.assets() when asset.urlParameter()
                  do (asset, assetIndex) =>
                    _id: asset.urlParameter()
                    index: assetIndex
                    asset: asset
                    scale: => @_assetScale asset

              index: index
              name: => sectionThing.fullName()
              noAssetsInstructions: => sectionThing.noAssetsInstructions?()
              assets: assets

        section =
          nameKey: @constructor.Sections["#{_.upperFirst sectionThingName}s"]
          groups: groups

        @["#{sectionThingName}sSection"] = section
  
    # Create artwork assets.
    @autorun (computation) =>
      @constructor.artworksWithAssets.subscribe @, characterId, @_artworkIds()
    
    @_artworkAssets = {}
    @_artworkAssetsDependency = new Tracker.Dependency
    
    @_artworksDictionary = new AE.ReactiveDictionary =>
      artworkIds = @_artworkIds()
      dictionary = {}
      
      PADB.Artwork.documents.find(_id: $in: artworkIds).forEach (artwork) =>
        dictionary[artwork._id] = dictionary
  
      dictionary
    ,
      added: (id) =>
        @_artworkAssets[id] = new PAA.PixelBoy.Apps.Drawing.Portfolio.ArtworkAsset id
        @_artworkAssetsDependency.changed()
  
      removed: (id) =>
        delete @_artworkAssets[id]
        @_artworkAssetsDependency.changed()
    
    # Create WIP artworks group.
    @_newArtworkAsset = new PAA.PixelBoy.Apps.Drawing.Portfolio.NewArtwork
    @_importArtworkAsset = new PAA.PixelBoy.Apps.Drawing.Portfolio.ImportArtwork

    @_wipArtworksGroup =
      index: 0
      name: => "WIP"
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
  
        # New artworks can be created if the player can edit art with built-in editors.
        # TODO: Enable ability to create artworks.
        if false # PAA.PixelBoy.Apps.Drawing.canEdit()
          assets.push
            _id: @_newArtworkAsset.urlParameter()
            index: assets.length
            asset: @_newArtworkAsset
            scale: => 1
  
        # Artworks can be imported if the player can edit or upload art made with external software.
        # TODO: Enable ability to import artworks.
        if false # PAA.PixelBoy.Apps.Drawing.canEdit() or PAA.PixelBoy.Apps.Drawing.canUpload()
          assets.push
            _id: @_importArtworkAsset.urlParameter()
            index: assets.length
            asset: @_importArtworkAsset
            scale: => 1
  
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

      sections.push @projectsSection if @projectsSection.groups().length
      sections.push @challengesSection if @challengesSection.groups().length
      sections.push @artworksSection if @artworksSection.groups().length

      # If the active section is not present anymore, close the section.
      if @activeSection and not @activeSection() in sections
        @activeSection null
        @activeGroup null
        @hoveredAsset null

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

    # Subscribe to character's projects.
    PAA.Practice.Project.forCharacterId.subscribe @, characterId

    # Prepare settings.
    editors = new PAA.PixelBoy.Apps.Drawing.Editors
    
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

  onDestroyed: ->
    super arguments...
    
    editor.destroy?() for editor in @_editors
  
    @_artworksDictionary.stop()
    @_newArtworkAsset.destroy()
    @_importArtworkAsset.destroy()

  _artworkIds: ->
    return [] unless artworks = PAA.PixelBoy.Apps.Drawing.state 'artworks'
    artwork.artworkId for artwork in artworks
