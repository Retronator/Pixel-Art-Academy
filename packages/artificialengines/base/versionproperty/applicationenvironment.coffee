AB = Artificial.Base

class AB.ApplicationEnvironment extends AB.VersionProperty
  @Types =
    Browser: 'Browser'
    Cordova: 'Cordova'
    Electron: 'Electron'
    Server: 'Server'
  
  if Meteor.isDesktop
    @setType @Types.Electron

  else if Meteor.isCordova
    @setType @Types.Electron
  
  else if Meteor.isClient
    @setType @Types.Browser
    
  else if Meteor.isServer
    @setType @Types.Server
