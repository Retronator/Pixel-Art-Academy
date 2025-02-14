AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class LOI.Components.Account.Inventory extends LOI.Components.Account.Page
  @register 'LandsOfIllusions.Components.Account.Inventory'
  @url: -> 'inventory'
  @displayName: -> 'Inventory'

  @initialize()

  renderRaw: -> true

  onCreated: ->
    super arguments...

    # Prepare items.
    RS.Item.all.subscribe @

    @items = new ComputedField =>
      return [] unless items = Retronator.user()?.items
      
      item.refresh() for item in items
      
      items

    @autorun (computation) =>
      for item in @items() when item.name
        AB.Translation.forId.subscribe @, item.name._id, AB.languagePreference()
        
    # Separate items into groups.
    @pixelArtAcademyItems = new ComputedField =>
      items = @items()
      selectedItems = []
  
      # First add any bundle the user owns.
      bundleKeys = []
  
      addKeys = (bundles) =>
        for value in _.values bundles
          if _.isObject value
            addKeys value
  
          else
            bundleKeys.push value
  
      addKeys RS.Items.CatalogKeys.Bundles.PixelArtAcademy
  
      for item in items
        selectedItems.push item if item.catalogKey in bundleKeys
  
      # Add all the game items.
      pixelArtAcademyKeys = []
  
      for value in _.values RS.Items.CatalogKeys.PixelArtAcademy
        pixelArtAcademyKeys.push value if _.isString value
  
      # Add avatar keys.
      pixelArtAcademyKeys.push RS.Items.CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
  
      # Now filter items to valid keys.
      for item in items
        selectedItems.push item if item.catalogKey in pixelArtAcademyKeys
  
      selectedItems
  
    @rewardItems = new ComputedField =>
      items = @items()
      selectedItems = []
  
      # Add all the kickstarter-exclusive items.
      rewardKeys = _.flatten [
        _.values RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter
        _.values RS.Items.CatalogKeys.PixelArtAcademy.Help
      ]
  
      # Add avatar keys.
      avatarKeys = RS.Items.CatalogKeys.LandsOfIllusions.Character.Avatar
      rewardKeys = rewardKeys.concat [avatarKeys.CustomItem, avatarKeys.UniqueItem, avatarKeys.UniqueCustomAvatar]
  
      # Add Patreon keys.
      patreonKeys = RS.Items.CatalogKeys.Retronator.Patreon
      rewardKeys = rewardKeys.concat [patreonKeys.PatreonKeycard, patreonKeys.EarlyBirdKeycard]
  
      for item in items
        selectedItems.push item if item.catalogKey in rewardKeys
  
      selectedItems
  
    @accessItems = new ComputedField =>
      items = @items()
      selectedItems = []
  
      # Add all the kickstarter-exclusive items.
      accessKeys = _.values RS.Items.CatalogKeys.Retropolis
  
      for item in items
        selectedItems.push item if item.catalogKey in accessKeys
  
      selectedItems
    
    @itemKeyItems = new ComputedField =>
      items = @items()
      selectedItems = []
      
      # Add all the Steam keys.
      steamLearnModeKeys = _.values RS.Items.CatalogKeys.PixelArtAcademy.Steam.LearnMode
      
      for item in items
        selectedItems.push item if item.catalogKey in steamLearnModeKeys
      
      selectedItems

    # Split items between two pages.
    @pageItems = new ComputedField =>
      firstPage = [[], [], [], []]
      secondPage = [[], [], [], []]

      pageItemLimit = 9
      itemCount = 0

      for items, bracketIndex in [@pixelArtAcademyItems(), @rewardItems(), @accessItems(), @itemKeyItems()]
        for item in items
          targetPage = if itemCount > pageItemLimit then secondPage else firstPage

          targetPage[bracketIndex].push item
          itemCount++

      [firstPage, secondPage]

    @otherSide = new ReactiveField false
    
    @selectedItem = new ReactiveField null
    @selectedItemKeyCode = new ReactiveField null
    
    # Update selected item to always come from updated items (since they will recompute during a claim).
    @autorun (computation) =>
      items = @items()
      
      Tracker.nonreactive =>
        return unless selectedItem = @selectedItem()
        @selectedItem _.find items, (item) => item.catalogKey is selectedItem.catalogKey

  displayedPixelArtAcademyItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][0]

  displayedRewardItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][1]

  displayedAccessItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][2]
  
  displayedItemKeyItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][3]
    
  showMoreRewards: ->
    not @otherSide() and @pageItems()[1][1].length

  showMoreAccess: ->
    not @otherSide() and @pageItems()[1][2].length

  showMoreItemKeyItems: ->
    not @otherSide() and @pageItems()[1][3].length
    
  name: ->
    item = @currentData()
    return "" unless item.name

    item.name.refresh()

    return "" unless name = AB.translate(item.name).text

    name = name.replace "—", "-"

    name

  pixelArtAcademyItemName: ->
    name = @name()

    name = name.replace "Pixel Art Academy - ", ""
    name = name.replace "Pixel Art Academy ", ""
    name = name.replace "Lands of Illusions - ", ""

    _.upperFirst name

  keycardClass: ->
    return unless user = Retronator.user()

    kickstarterKeys = RS.Items.CatalogKeys.PixelArtAcademy.Kickstarter

    keycards =
      white: kickstarterKeys.WhiteKeycard
      yellow: kickstarterKeys.YellowKeycard
      cyan: kickstarterKeys.CyanKeycard
      green: kickstarterKeys.GreenKeycard
      magenta: kickstarterKeys.MagentaKeycard
      red: kickstarterKeys.RedKeycard
      blue: kickstarterKeys.BlueKeycard
      black: kickstarterKeys.BlackKeycard
      zx: kickstarterKeys.ZXBlackKeycard
      nes: kickstarterKeys.NESBlackKeycard

    for keycardClass, keycardKey of keycards
      return keycardClass if user.hasItem keycardKey

    patreonKeys = RS.Items.CatalogKeys.Retronator.Patreon
    return 'patreon-early' if user.hasItem patreonKeys.EarlyBirdKeycard
    return 'patreon' if user.hasItem patreonKeys.PatreonKeycard

    # Otherwise return the default player keycard.
    'default'

  keycardImage: ->
    @versionedUrl "/landsofillusions/components/account/inventory/keycards/#{@keycardClass()}.png"

  otherSideClass: ->
    'other-side' if @otherSide()

  showTurn: ->
    pageItems = @pageItems()[1]
    _.sum (group.length for group in pageItems)
  
  selectedItemKeyClass: ->
    'item-key' if @selectedItemIsItemKey()
    
  selectedItemIsItemKey: ->
    @selectedItem() in @itemKeyItems()
    
  events: ->
    super(arguments...).concat
      'click .turn': @onClickTurn
      'click .item .name': @onClickItemName
      'click': @onClick

  onClickTurn: (event) ->
    @otherSide not @otherSide()
    @selectedItem null

    $page = $(event.target).closest('.page')
    $page.toggleClass 'flipped'

  onClickItemName: (event) ->
    item = @currentData()

    @selectedItem item
    @selectedItemKeyCode null
    
    if item in @itemKeyItems()
      RS.Item.Key.retrieveForItem item._id, (error, result) =>
        if error
          console.error error
          LOI.adventure.showDialogMessage error.reason
          return
        
        @selectedItemKeyCode result

  onClick: (event) ->
    $target = $(event.target)
    return if $target.closest('.item .name').length
    return if $target.closest('.selected-item.item-key').length and not $target.closest('.unload-info').length

    @selectedItem null
