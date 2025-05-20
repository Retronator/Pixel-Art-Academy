AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Editor.ColorHelp
  # hintStyle: the shape of the hints (dots by default)
  # errorStyle: how to display when a mismatch happened (or null if no error should be shown)
  # colorNames: how to show color names
  #   mode: mode selection when to show color names when hovering over a pixel or palette color (or null if no names should be shown)
  #   delayDuration: number of seconds required to hover
  @stateAddress = new LOI.StateAddress "things.PixelPad.Apps.Drawing.Editor.ColorHelp"
  @state = new LOI.StateObject address: @stateAddress

  @HintStyle =
    Dots: 'Dots'
    Symbols: 'Symbols'
    
  @ErrorStyle =
    PixelOutline: 'PixelOutline'
    HintOutline: 'HintOutline'
    HintGlow: 'HintGlow'
    
  @NamesMode =
    ColorPicker: 'ColorPicker'
    Always: 'Always'
    
  @symbols = """
    ✚♥♦★
    ☾▲▙◢
    ⚑▶▛◣
    ⌘▼▜◤
    ▰◀▟#
    *↖↗↘↙
    ◇▢◸◹◺◿◻▱
    ←↑→↓
    ☺☹+–=
    ◈◬◉✙◍◎
    ◘▤▥▣▩
    &%[]{}<>?✓✕
    ▦▧▨◙◧◨◩◪
    ◐◑◒◓◔◕
    ↔↺↻▵▹▿◃
    ◰◱◲◳
    ⇐⇒⇔⇕⇖⇗⇘⇙
    ◴◵◶◷◽◾
    0123456789
    ABCDEFGHIJKLMNOPQRSTUVWXYZ
    ↕♣♠♫@♭♪✜
    ☀☂☻☼♯✔☽
    abcdefghijklmnopqrstuvwxyz
  """.match /[^\s]/g
    
  @hintStyle: -> @state('hintStyle') or @HintStyle.Dots
  @errorStyle: -> @state('errorStyle') or null
  @colorNamesMode: -> @state('colorNames')?.mode or null
