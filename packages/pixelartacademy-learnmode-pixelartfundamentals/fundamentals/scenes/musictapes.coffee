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
      title: 'musicdisk01'
      artist: 'Extent of the Jam'
    
    tapes
