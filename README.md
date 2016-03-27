# Pixel Art Academy

An adventure game for learning to draw.

As explained in [Lands of Illusions](https://github.com/Retronator/Lands-of-Illusions) package repository, you have to create a settings file that points to where you have LOI server running.

You also need twitter and amazon services keys in there for Pixel Dailies modules and for artwork uploading to work. So the settings file for PAA should look like this:

```
{
  "amazonWebServices": {
    "accessKey": "enterhere",
    "secret": "enterhere"
  },
  "twitter": {
    "consumerKey": "enterhere",
    "secret": "enterhere"
  },
  "public": {
    "landsOfIllusionsUrl": "http://localhost.landsofillusions.world:3000"
  }
}
```

And then you run the server with a terminal script:

```
export MONGO_URL=mongodb://localhost.landsofillusions.world:3001/meteor
meteor run --port 3005 --settings /path/to/your/pixelartacademy-settings.json
```
