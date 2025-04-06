AE = Artificial.Everywhere
AT = Artificial.Telepathy
RA = Retronator.Accounts
LOI = LandsOfIllusions
Request = request

LOI.Assets.Pages.Admin.Palettes.Scripts.importLospec.method (slug) ->
  check slug, String
  RA.authorizeAdmin()
  
  console.log "Importing", slug, "from Lospec."
  
  paletteUrl = "https://Lospec.com/palette-list/#{slug}.json"
  paletteResponse = Request.getSync paletteUrl
  
  try
    paletteData = JSON.parse paletteResponse.body
    
  catch error
    console.error error, paletteResponse.body
    throw new AE.ExternalException "Response from Lospec is not valid JSON."
    
  console.log "Received", paletteData
  
  ramps = for colorHex in paletteData.colors
    shades: [new THREE.Color("##{colorHex}").toObject()]
    
  palette =
    name: paletteData.name
    ramps: ramps
    lospecSlug: slug
    
  palette.lospecAuthor = paletteData.author if paletteData.author
  
  LOI.Assets.Palette.documents.insert palette
  
LOI.Assets.Pages.Admin.Palettes.Scripts.convertRampsToShades.method (paletteId) ->
  check paletteId, Match.DocumentId
  RA.authorizeAdmin()
  
  palette = LOI.Assets.Palette.documents.findOne paletteId
  
  ramps = [
    shades: _.flatten (ramp.shades for ramp in palette.ramps)
  ]
  
  LOI.Assets.Palette.documents.update paletteId, $set: {ramps}
