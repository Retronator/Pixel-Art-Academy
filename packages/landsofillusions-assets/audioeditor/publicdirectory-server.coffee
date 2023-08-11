RA = Retronator.Accounts
LOI = LandsOfIllusions

fileSystem = require 'fs'

LOI.Assets.AudioEditor.PublicDirectory.allSoundFiles.publish ->
  # Only admins (and later editors) can see all the sounds.
  RA.authorizeAdmin userId: @userId or null
  
  meteorRoot = fileSystem.realpathSync "#{process.cwd()}/../"
  publicPath = "#{meteorRoot}/web.browser/app/"
  
  soundExtensions = ['mp3', 'wav', 'm4a']
  
  scanDirectory = (relativeDirectoryPath) =>
    directoryEntries = fileSystem.readdirSync "#{publicPath}#{relativeDirectoryPath}", withFileTypes: true
    
    for directoryEntry in directoryEntries
      if directoryEntry.isDirectory() and not directoryEntry.isSymbolicLink()
        scanDirectory "#{relativeDirectoryPath}#{directoryEntry.name}/"
        
      else if directoryEntry.isFile() and directoryEntry.name[directoryEntry.name.indexOf('.') + 1..] in soundExtensions
        relativeFilePath = "#{relativeDirectoryPath}#{directoryEntry.name}"
        
        @added LOI.Assets.AudioEditor.PublicDirectory.soundFiles.name, relativeFilePath,
          name: relativeFilePath
        
    @ready()
  
  scanDirectory ''
  
  # Explicitly return nothing since we're handling the publishing ourselves.
  return
