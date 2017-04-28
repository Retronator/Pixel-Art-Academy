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
    super

    @subscribe RS.Transactions.Item.all

    # Subscribe to item names.
    @autorun (computation) =>
      for item in @items() when item.name
        @subscribe 'Artificial.Babel.Translation.withId', item.name._id, AB.userLanguagePreference()

    @otherSide = new ReactiveField false

    # Split items between two pages.
    @pageItems = new ComputedField =>
      firstPage = [[], [], []]
      secondPage = [[], [], []]

      pageItemLimit = 9
      itemCount = 0

      for items, bracketIndex in [@pixelArtAcademyItems(), @rewardItems(), @accessItems()]
        for item in items
          targetPage = if itemCount > pageItemLimit then secondPage else firstPage

          targetPage[bracketIndex].push item
          itemCount++

      [firstPage, secondPage]

    @selectedItem = new ReactiveField null

  items: ->
    return [] unless items = Retronator.user()?.items

    item.refresh() for item in items

    items

  pixelArtAcademyItems: ->
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

  rewardItems: ->
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

    for item in items
      selectedItems.push item if item.catalogKey in rewardKeys

    selectedItems

  accessItems: ->
    items = @items()
    selectedItems = []

    # Add all the kickstarter-exclusive items.
    accessKeys = _.values RS.Items.CatalogKeys.Retropolis

    for item in items
      selectedItems.push item if item.catalogKey in accessKeys

    selectedItems

  displayedPixelArtAcademyItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][0]

  displayedRewardItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][1]

  displayedAccessItems: ->
    pageIndex = if @otherSide() then 1 else 0
    @pageItems()[pageIndex][2]

  showMoreRewards: ->
    not @otherSide() and @pageItems()[1][1].length

  showMoreAccess: ->
    not @otherSide() and @pageItems()[1][2].length

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

    name

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

    # Otherwise return the default player keycard.
    'default'

  keycardImage: ->
    @versionedUrl "/landsofillusions/components/account/inventory/keycards/#{@keycardClass()}.png"

  otherSideClass: ->
    'other-side' if @otherSide()

  showTurn: ->
    pageItems = @pageItems()[1]
    _.sum (group.length for group in pageItems)
    
  events: ->
    super.concat
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

  onClick: (event) ->
    return if $(event.target).closest('.item .name').length

    @selectedItem null
