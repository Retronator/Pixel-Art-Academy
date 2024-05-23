LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.MusicTapes extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.MusicTapes'

  @location: -> PAA.Music.Tapes

  @initialize()
  
  things: ->
    tapes = []
    
    # You immediately get the first tapes.
    # TODO: When more original compositions are added, move these as rewards later on.
    tapes.push
      artist: 'Extent of the Jam'
      title: 'musicdisk01'
    
    tapes.push
      artist: 'Shnabubula'
      title: 'Finding the Groove'

    # Tape for Elements of art: line.
    if PAA.Tutorials.Drawing.ElementsOfArt.Line.completed()
      tapes.push
        artist: 'HOME'
        title: 'Resting State'
      
    # Tape for Pixel art lines.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.completed()
      tapes.push
        artist: 'glaciære'
        'sides.0.title': 'shower'
        
    # Tape for Pixel art diagonals.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Diagonals.completed()
      tapes.push
        artist: 'Revolution Void'
        title: 'The Politics of Desire'
    
    # Tape for Pixel art curves.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Curves.completed()
      tapes.push
        artist: 'State Azure'
        title: 'Stellar Descent'
      
    # Tape for Pixel art line width.
    if PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.LineWidth.completed()
      tapes.push
        artist: 'Three Chain Links'
        'sides.0.title': 'The Happiest Days Of Our Lives'
    
    tapes
