AC = Artificial.Control
AM = Artificial.Mirage

class AM.ShortcutHelper
  @PlatformConventions:
    MacOS: 'MacOS'
    Windows: 'Windows'
    Linux: 'Linux'

  if Meteor.isClient
    @currentPlatformConvention = @PlatformConventions.MacOS if navigator.platform.match /mac/i
    @currentPlatformConvention = @PlatformConventions.Windows if navigator.platform.match /win/i
    @currentPlatformConvention = @PlatformConventions.Linux if navigator.platform.match /linux/i

  @getShortcutString: (shortcut, platformConvention = @currentPlatformConvention) ->
    return unless shortcut

    string = ''

    # Control on macOS comes first.
    if not shortcut.commandOrControl and shortcut.control
      switch platformConvention
        when @PlatformConventions.MacOS then string += '⌃'

    if shortcut.alt
      switch platformConvention
        when @PlatformConventions.MacOS then string += '⌥'
        when @PlatformConventions.Windows then string += 'Alt+'
        when @PlatformConventions.Linux then string += 'Alt+'

    if shortcut.shift
      switch platformConvention
        when @PlatformConventions.MacOS then string += '⇧'
        when @PlatformConventions.Windows then string += 'Shift+'
        when @PlatformConventions.Linux then string += 'Shift+'

    if shortcut.commandOrControl
      switch platformConvention
        when @PlatformConventions.MacOS then string += '⌘'
        when @PlatformConventions.Windows then string += 'Ctrl+'
        when @PlatformConventions.Linux then string += 'Ctrl+'

    else
      if shortcut.command and platformConvention is @PlatformConventions.MacOS then string += '⌘'
      if shortcut.windows and platformConvention is @PlatformConventions.Windows then string += 'Win'
      if shortcut.super and platformConvention is @PlatformConventions.Linux then string += 'Super'

    # See if we have a direct label given to represent the key.
    if shortcut.keyLabel
      string += shortcut.keyLabel
      return string

    for keyName, value of AC.Keys
      if value is shortcut.key
        replacements = []
        replacements[AC.Keys.left] = '←'
        replacements[AC.Keys.up] = '↑'
        replacements[AC.Keys.right] = '→'
        replacements[AC.Keys.down] = '↓'
        replacements[AC.Keys.semicolon] = ';'
        replacements[AC.Keys.equalSign] = '='
        replacements[AC.Keys.comma] = ','
        replacements[AC.Keys.dash] = '-'
        replacements[AC.Keys.period] = '.'
        replacements[AC.Keys.forwardSlash] = '/'
        replacements[AC.Keys.graveAccent] = '`'
        replacements[AC.Keys.openBracket] = '['
        replacements[AC.Keys.backslash] = '\\'
        replacements[AC.Keys.closeBracket] = ']'
        replacements[AC.Keys.singleQuote] = '\''

        switch platformConvention
          when @PlatformConventions.MacOS
            replacements[AC.Keys.backspace] = '⌫'
            replacements[AC.Keys.tab] = '⇥'
            replacements[AC.Keys.return] = '⏎'
            replacements[AC.Keys.capsLock] = '⇪'
            replacements[AC.Keys.escape] = '⎋'
            replacements[AC.Keys.space] = '␣'
            replacements[AC.Keys.delete] = '⌦'

        if replacements[value]
          string += replacements[value]

        else if AC.Keys.f1 <= value <= AC.Keys.f12
          string += _.upperFirst keyName

        else
          string += _.startCase keyName

        return string

    # We couldn't find the key of this shortcut.
    null
