AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Music
  @StartTimeoutDuration = 2
  
  @FadeDurations =
    InGameMusicModeOffFadeOut: 5
    InGameMusicModeOffFadeIn: 3
    MenuFadeOut: 0.5
    MenuFadeIn: 3
    DynamicSoundtrackToMusicAppFadeOut: 1
    DynamicSoundtrackSongChangeFadeOut: 5
    PrePlayingMusicOnLoadFadeIn: 3
  
if Meteor.isServer
  # Export all tape documents.
  AM.DatabaseContent.addToExport ->
    PAA.Music.Tape.documents.fetch()
