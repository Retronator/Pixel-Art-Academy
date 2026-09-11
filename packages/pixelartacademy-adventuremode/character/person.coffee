AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

LOI.Character.Person::recentTaskEntries = (requireInitialHangoutCompleted) -> throw new AE.NotImplementedException "Person must provide recent tasks."
LOI.Character.Person::getTaskEntries = (query) -> throw new AE.NotImplementedException "Person must implement querying tasks."
