PAA = PixelArtAcademy

Document.startup ->
  return if Meteor.settings.startEmpty

  addTape = (tape) ->
    # See if we already have this tape.
    slug = PAA.Music.Tape.createSlug tape

    if existingTape = PAA.Music.Tape.documents.findOne {slug}
      # See if any of the fields have changed.
      changed = false
      
      for property, value of tape
        unless EJSON.equals value, existingTape[property]
          changed = true
          break
          
      return unless changed
    
      # Update last edit time as well.
      tape.lastEditTime = new Date
      
      PAA.Music.Tape.documents.update existingTape._id,
        $set: tape
    
    else
      # This tape is not yet present.
      PAA.Music.Tape.documents.upsert
        title: tape.title
        artist: tape.artist
      ,
        $set: tape
        
  duration = (minutes, seconds) -> minutes * 60 + seconds

  addTape
    artist: 'Extent of the Jam'
    title: 'musicdisk01'
    styleClass: 'c60'
    gain: 1.6
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
  
  addTape
    artist: 'glaciære'
    styleClass: 'c90 single-row'
    gain: 1.1
    sides: [
      title: 'shower'
      tracks: [
        title: 'Salt Water'
        duration: duration 3, 46
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 01 Salt Water.mp3'
      ,
        title: 'Hot Chocolate'
        duration: duration 3, 41
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 02 Hot Chocolate.mp3'
      ,
        title: 'Galápagos Penguin'
        duration: duration 4, 8
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 03 Galapagos Penguin.mp3'
      ,
        title: 'An Old Computer Game You Can Barely Remember'
        duration: duration 3, 19
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 04 An Old Computer Game You Can Barely Remember.mp3'
      ,
        title: 'Moments of Microsleep'
        duration: duration 2, 59
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 05 Moments of Microsleep.mp3'
      ,
        title: 'Drizzle'
        duration: duration 3, 40
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 06 Drizzle.mp3'
      ,
        title: 'The Water\'s Warm, The Air Is Cool (feat. Kissonance)'
        duration: duration 4, 27
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 07 The Waters Warm, The Air Is Cool (feat. Kissonance).mp3'
      ,
        title: 'Nostalgia'
        duration: duration 3, 12
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 08 Nostalgia.mp3'
      ,
        title: 'From the Sauna to the Snow'
        duration: duration 3, 32
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 09 From the Sauna to the Snow.mp3'
      ,
        title: 'Thank You'
        duration: duration 4, 10
        url: '/pixelartacademy/music/glaciaere - shower/glaciaere - shower - 10 Thank You.mp3'
      ]
    ,
      title: 'two months of moments'
      tracks: [
        title: 'Into the Maelstrom'
        duration: duration 3, 57
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 01 Into the Maelstrom.mp3'
      ,
        title: 'Be Still My Heart'
        duration: duration 5, 30
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 02 Be Still My Heart.mp3'
      ,
        title: 'Bittersweet'
        duration: duration 3, 5
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 03 Bittersweet.mp3'
      ,
        title: 'Stars Forced To Shine'
        duration: duration 3, 38
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 04 Stars Forced To Shine.mp3'
      ,
        title: 'What You Felt Deep Inside'
        duration: duration 3, 16
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 05 What You Felt Deep Inside.mp3'
      ,
        title: 'When Your Eyes Meet From Across the Bar'
        duration: duration 2, 15
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 06 When Your Eyes Meet From Across the Bar.mp3'
      ,
        title: 'Confidence, Baby'
        duration: duration 3, 36
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 07 Confidence, Baby.mp3'
      ,
        title: 'The Sun Is Rising'
        duration: duration 4, 10
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 08 The Sun Is Rising.mp3'
      ,
        title: 'Blue Raspberry Flavoured Lip Gloss'
        duration: duration 4, 24
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 09 Blue Raspberry Flavoured Lip Gloss.mp3'
      ,
        title: 'The Next Lips That Touch Mine'
        duration: duration 4, 54
        url: '/pixelartacademy/music/glaciaere - two months of moments/glaciaere - two months of moments - 10 The Next Lips That Touch Mine.mp3'
      ,
      ]
    ]
  
  addTape
    artist: 'HOME'
    title: 'Resting State'
    styleClass: 'c60 double-column'
    gain: 1.1
    sides: [
      tracks: [
        title: '1'
        duration: duration 1, 22
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 01 1.mp3'
      ,
        title: '2'
        duration: duration 1, 47
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 02 2.mp3'
      ,
        title: '3'
        duration: duration 0, 56
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 03 3.mp3'
      ,
        title: '4'
        duration: duration 1, 21
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 04 4.mp3'
      ,
        title: '5'
        duration: duration 1, 17
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 05 5.mp3'
      ,
        title: '6'
        duration: duration 1, 22
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 06 6.mp3'
      ,
        title: '7'
        duration: duration 1, 26
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 07 7.mp3'
      ,
        title: '8'
        duration: duration 3, 17
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 08 8.mp3'
      ,
        title: '9'
        duration: duration 2, 55
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 09 9.mp3'
      ,
        title: '10'
        duration: duration 1, 24
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 10 10.mp3'
      ,
        title: '11'
        duration: duration 1, 37
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 11 11.mp3'
      ,
        title: '12'
        duration: duration 2, 18
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 12 12.mp3'
      ,
        title: '13'
        duration: duration 1, 13
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 13 13.mp3'
      ,
        title: '14'
        duration: duration 1, 21
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 14 14.mp3'
      ,
        title: '15'
        duration: duration 1, 39
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 15 15.mp3'
      ,
        title: '16'
        duration: duration 0, 32
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 16 16.mp3'
      ,
        title: '17'
        duration: duration 1, 31
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 17 17.mp3'
      ]
    ,
      tracks: [
        title: '18'
        duration: duration 1, 33
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 18 18.mp3'
      ,
        title: '19'
        duration: duration 1,25
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 19 19.mp3'
      ,
        title: '20'
        duration: duration 1, 33
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 20 20.mp3'
      ,
        title: '21'
        duration: duration 2, 11
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 21 21.mp3'
      ,
        title: '22'
        duration: duration 1, 25
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 22 22.mp3'
      ,
        title: '23'
        duration: duration 1, 53
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 23 23.mp3'
      ,
        title: '24'
        duration: duration 1, 33
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 24 24.mp3'
      ,
        title: '25'
        duration: duration 0, 54
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 25 25.mp3'
      ,
        title: '26'
        duration: duration 0, 58
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 26 26.mp3'
      ,
        title: '27'
        duration: duration 0, 56
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 27 27.mp3'
      ,
        title: '28'
        duration: duration 0, 27
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 28 28.mp3'
      ,
        title: '29'
        duration: duration 1, 37
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 29 29.mp3'
      ,
        title: '30'
        duration: duration 1, 45
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 30 30.mp3'
      ,
        title: '31'
        duration: duration 0, 51
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 31 31.mp3'
      ,
        title: '32'
        duration: duration 1, 52
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 32 32.mp3'
      ,
        title: '33'
        duration: duration 1, 52
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 33 33.mp3'
      ,
        title: '34'
        duration: duration 1, 38
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 34 34.mp3'
      ,
        title: '35'
        duration: duration 2, 10
        url: '/pixelartacademy/music/HOME - Resting State/HOME - Resting State - 35 35.mp3'
      ]
    ]
    
  addTape
    artist: 'Revolution Void'
    title: 'The Politics of Desire'
    styleClass: 'c60'
    gain: 1.1
    sides: [
      tracks: [
        title: 'Line of Flight'
        duration: duration 6, 1
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/01 Revolution Void - Line of Flight.mp3'
      ,
        title: 'Time Flux'
        duration: duration 3, 56
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/02 Revolution Void - Time Flux.mp3'
      ,
        title: 'Someone Else\'s Memories'
        duration: duration 3, 44
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/03 Revolution Void - Someone Elses Memories.mp3'
      ,
        title: 'Tree Tenants'
        duration: duration 4, 50
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/04 Revolution Void - Tree Tenants.mp3'
      ,
        title: 'Telluric Undercurrent'
        duration: duration 6, 44
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/05 Revolution Void - Telluric Undercurrent.mp3'
      ,
      ]
    ,
      tracks: [
        title: 'Outer Orbit'
        duration: duration 5, 7
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/06 Revolution Void - Outer Orbit.mp3'
      ,
        title: 'How Exciting'
        duration: duration 4, 10
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/07 Revolution Void - How Exciting.mp3'
      ,
        title: 'The Simulation Hypothesis'
        duration: duration 5, 13
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/08 Revolution Void - The Simulation Hypothesis.mp3'
      ,
        title: 'The Narrative Changes'
        duration: duration 2, 18
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/09 Revolution Void - The Narrative Changes.mp3'
      ,
        title: 'Scattered Knowledge'
        duration: duration 4, 7
        url: '/pixelartacademy/music/Revolution Void - The Politics of Desire/10 Revolution Void - Scattered Knowledge.mp3'
      ,
      ]
    ]
    
  addTape
    artist: 'Shnabubula'
    title: 'Finding the Groove'
    styleClass: 'c60'
    gain: 2.4
    sides: [
      tracks: [
        title: 'Welcome to Retropolis'
        duration: duration 6, 42
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 01 Welcome to Retropolis.mp3'
      ,
        title: 'Game and Chill'
        duration: duration 6, 59
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 02 Game and Chill.mp3'
      ,
        title: 'Skyline Drive'
        duration: duration 7, 32
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 03 Skyline Drive.mp3'
      ,
        title: 'The Brothers Smith'
        duration: duration 6, 2
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 04 The Brothers Smith.mp3'
      ]
    ,
      tracks: [
        title: 'Neon Rainbow Sunset Horizon'
        duration: duration 4, 35
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 05 Neon Rainbow Sunset Horizon.mp3'
      ,
        title: 'Longing for the City'
        duration: duration 7, 41
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 06 Longing for the City.mp3'
      ,
        title: 'Pink Man Strut'
        duration: duration 4, 45
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 07 Pink Man Strut.mp3'
      ,
        title: 'Peralta'
        duration: duration 8, 4
        url: '/pixelartacademy/music/Shnabubula - Piano Storybook Vol. 3- Finding the Groove/Shnabubula - Piano Storybook Vol. 3- Finding the Groove - 08 Peralta.mp3'
      ]
    ]
    
  addTape
    artist: 'State Azure'
    title: 'Stellar Descent'
    styleClass: 'c120 single-row'
    gain: 0.9
    sides: [
      tracks: [
        title: 'Stellar Drift'
        duration: duration 4, 52
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 01 Stellar Drift.mp3'
      ,
        title: 'Archetype'
        duration: duration 5, 55
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 02 Archetype.mp3'
      ,
        title: 'Etheric Labyrinth'
        duration: duration 8, 24
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 03 Etheric Labyrinth.mp3'
      ,
        title: 'Serpentine'
        duration: duration 8, 23
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 04 Serpentine.mp3'
      ,
        title: 'The Roche Limit'
        duration: duration 6, 49
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 05 The Roche Limit.mp3'
      ,
        title: 'A Function of Time'
        duration: duration 7, 28
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 06 A Function of Time.mp3'
      ,
        title: 'Fractal Life'
        duration: duration 5, 37
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 07 Fractal Life.mp3'
      ,
        title: 'The Tesseract'
        duration: duration 7, 14
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 08 The Tesseract.mp3'
      ]
    ,
      tracks: [
        title: 'Star Cascade'
        duration: duration 5, 4
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 09 Star Cascade.mp3'
      ,
        title: 'Tarantula'
        duration: duration 6, 38
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 10 Tarantula.mp3'
      ,
        title: 'Procyon Sphere'
        duration: duration 6, 6
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 11 Procyon Sphere.mp3'
      ,
        title: 'Domain of the Resonant Heart'
        duration: duration 6, 17
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 12 Domain of the Resonant Heart.mp3'
      ,
        title: 'Sublunar'
        duration: duration 6, 48
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 13 Sublunar.mp3'
      ,
        title: 'Heliopulse'
        duration: duration 7, 11
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 14 Heliopulse.mp3'
      ,
        title: 'Chase the Earth'
        duration: duration 6, 6
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 15 Chase the Earth.mp3'
      ,
        title: 'Whispers of Stars'
        duration: duration 6, 47
        url: '/pixelartacademy/music/State Azure - Stellar Descent/State Azure - Stellar Descent - 16 Whispers of Stars.mp3'
      ]
    ]
  
  addTape
    artist: 'Three Chain Links'
    styleClass: 'c60 single-row'
    gain: 0.8
    sides: [
      title: 'The Happiest Days Of Our Lives'
      tracks: [
        title: 'Happiest Days'
        duration: duration 3, 50
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 01 Happiest Days.mp3'
      ,
        title: 'Drive Fast'
        duration: duration 3, 1
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 02 Drive Fast.mp3'
      ,
        title: 'Gray Is The Sky'
        duration: duration 3, 7
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 03 Gray Is The Sky.mp3'
      ,
        title: 'The City, It Speaks To Me'
        duration: duration 3, 14
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 04 The City, It Speaks To Me.mp3'
      ,
        title: 'It Can\'t Be Bargained With'
        duration: duration 3, 5
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 05 It Cant Be Bargained With.mp3'
      ,
        title: 'Cracked Streets And Broken Windows'
        duration: duration 3, 57
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 06 Cracked Streets And Broken Windows.mp3'
      ,
        title: 'Dance Harder'
        duration: duration 3, 33
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 07 Dance Harder.mp3'
      ,
        title: 'Heavy Traffic'
        duration: duration 3, 28
        url: '/pixelartacademy/music/Three Chain Links - The Happiest Days Of Our Lives/Three Chain Links - The Happiest Days Of Our Lives - 08 Heavy Traffic.mp3'
      ]
    ,
      title: 'Interface'
      tracks: [
        title: 'Interface'
        duration: duration 4, 20
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 01 Interface.mp3'
      ,
        title: 'Resetting the grid'
        duration: duration 3, 17
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 02 Resetting the grid.mp3'
      ,
        title: 'Giving the cables life'
        duration: duration 1, 56
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 03 Giving the cables life.mp3'
      ,
        title: 'Rewiring the mainframe'
        duration: duration 2, 53
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 04 Rewiring the mainframe.mp3'
      ,
        title: 'Reformatting in progress'
        duration: duration 2, 38
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 05 Reformatting in progress.mp3'
      ,
        title: 'Operating system load complete'
        duration: duration 2, 12
        url: '/pixelartacademy/music/Three Chain Links - Interface/Three Chain Links - Interface - 06 Operating system load complete.mp3'
      ]
    ]
    
###
  addTape
    artist: ''
    title: ''
    styleClass: ''
    sides: [
      title: ''
      tracks: [
        title: ''
        duration: duration ,
        url: '/pixelartacademy/music//'
      ]
    ]
###
