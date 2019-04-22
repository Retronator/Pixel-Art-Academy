AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

LOI.Character.Person::recentTasks = -> throw AE.NotImplementedException "Person must provide recent tasks."
LOI.Character.Person::getTasks = (query) -> throw AE.NotImplementedException "Person must implement querying tasks."
