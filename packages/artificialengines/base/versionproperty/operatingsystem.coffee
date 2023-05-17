AB = Artificial.Base

if Meteor.isServer
  process = require "process"

class AB.OperatingSystem extends AB.VersionProperty
  @Types =
    MacOS: 'MacOS'
    Windows: 'Windows'
    Linux: 'Linux'
    IPadOS: 'IPadOS'
    IOS: 'IOS'
  
  if Meteor.isDesktop
    Desktop.call('desktop', 'getProcessPlatform').then (processPlatform) =>
      @setType switch processPlatform
        when 'darwin' then @Types.MacOS
        when 'win32' then @Types.Windows
        when 'linux' then @Types.Linux
  
  else if Meteor.isCordova
    onDeviceReady = =>
      switch device.platform
        when 'iOS' then @setType if device.model.match /ipad/i then @Types.IPadOS else @Types.IOS
      
    document.addEventListener "deviceready", onDeviceReady, false
  
  else if Meteor.isClient
    @setType @Types.MacOS if navigator.platform.match /mac/i
    @setType @Types.Windows if navigator.platform.match /win/i
    @setType @Types.Linux if navigator.platform.match /linux/i
    
  else if Meteor.isServer
    processPlatform = process.platform
    @setType switch processPlatform
      when 'darwin' then @Types.MacOS
      when 'win32' then @Types.Windows
      when 'linux' then @Types.Linux
