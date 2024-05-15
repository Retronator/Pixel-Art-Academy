PAA = PixelArtAcademy

Document.startup ->
  return if Meteor.settings.startEmpty

  addTape = (tape) ->
    PAA.Music.Tape.documents.upsert
      title: tape.title
      artist: tape.artist
    ,
      $set:
        tape
      
  duration = (minutes, seconds) -> minutes * 60 + seconds

  addTape
    title: 'musicdisk01'
    artist: 'Extent of the Jam'
    sides: [
      tracks: [
        title: 'Xcessiv'
        duration: duration 4, 30
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 01 Xcessiv.mp3'
      ,
        title: 'Electric Grid'
        duration: duration 3, 44
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 02 Electric Grid.mp3'
      ,
        title: 'Lifespan'
        duration: duration 3, 29
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 03 Lifespan.mp3'
      ,
        title: 'Trash the Stack'
        duration: duration 2, 49
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 04 Trash the Stack.mp3'
      ,
        title: 'Jamulations (3-Mix)'
        duration: duration 2, 54
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 05 Jamulations (3-Mix).mp3'
      ,
        title: 'Burn Zone'
        duration: duration 3, 4
        url: '/pixelartacademy/music/Extent of the Jam - musicdisk01/Extent of the Jam - musicdisk01 - 06 Burn Zone.mp3'
      ]
    ]
