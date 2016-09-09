RS = Retronator.Store

RS.Items.CatalogKeys =
  PixelArtAcademy:
    FoundationYear: ''
    FreshmanYear: ''
    SophomoreYear: ''
    JuniorYear: ''
    SeniorYear: ''
    Help:
      ClassHelp: ''
      Paintover: ''
      PaintoverVideo: ''
    Kickstarter:
      WhiteKeycard: ''
      YellowKeycard: ''
      CyanKeycard: ''
      GreenKeycard: ''
      MagentaKeycard: ''
      RedKeycard: ''
      BlueKeycard: ''
      BlackKeycard: ''
      ZXBlackKeycard: ''
      NESBlackKeycard: ''
      RetropolisAcademyOfArtYearbook: ''
      ClassOf2016Artwork: ''
      ZXCosmopolis: ''
      PixelChinaMountains: ''
  Retropolis:
    DayPass: ''
    NightlifePass: ''
    IdeaGardenAccess: ''
    SecretLabAccess: ''
    PatronClubMember: ''
    Investor: ''
    VIP: ''
  LandsOfIllusions:
    Character:
      Creation: ''
      Avatar:
        AvatarSelection: ''
        AvatarEditor: ''
        CustomItem: ''
        UniqueItem: ''
        UniqueCustomAvatar: ''
  Retronator:
    Admin: ''

  Bundles:
    PixelArtAcademy:
      PreOrder:
        BasicGame: ''
        FullGame: ''
        AlphaAccess: ''
        AvatarEditorUpgrade: ''
        FoundationYearUpgrade: ''
      Kickstarter:
        NoReward: ''
        BasicGame: ''
        EarlyFullGame: ''
        FullGame: ''
        EarlyAlphaAccess: ''
        AlphaAccess: ''
        AvatarTrack:
          CustomItem: ''
          UniqueItem: ''
          UniqueCustomAvatar: ''
        ArtistTrack:
          ClassHelp: ''
          Paintover: ''
          VideoPaintover: ''
        ArtCollector:
          ZXCosmopolis: ''
          PixelChinaMountains: ''
      Complimentary:
        BasicGame: ''
        FullGame: ''
        AlphaAccess: ''
        IdeaGarden: ''
        SecretLab: ''
        PatronClub: ''
        Investor: ''
        VIP: ''
        Press: ''

# Generate catalog keys.
transformCatalogKey = (prefix, keys) ->
  # Nothing to do on leaf nodes, simply return the text to be set.
  return prefix unless _.isObject keys

  # We are on an object node so transform each property in turn.
  for key of keys
    keys[key] = transformCatalogKey "#{prefix}.#{key}", keys[key]

  # Return the modified keys.
  keys

for key of RS.Items.CatalogKeys
  RS.Items.CatalogKeys[key] = transformCatalogKey key, RS.Items.CatalogKeys[key]
