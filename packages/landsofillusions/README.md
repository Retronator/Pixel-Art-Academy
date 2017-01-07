# Lands of Illusions
Game engine for Pixel Art Academy, Retropolis and beyond.

## Running LOI projects

For any project that uses the LOI package, running the project is a bit more involved than simply running `meteor`.

You will need to run the LOI server, which will host the database and provide user creation/login capabilities. See
the [Lands of Illusions Server](https://github.com/Retronator/Lands-of-Illusions-Server) repository for info how
to run it.

First step is to run the meteor server for LOI, which in development will run on `localhost:3000`. MongoDB in this case
will run at `localhost:3001`.

In the settings file of the project using the LOI package, you need to specify the location of the LOI server.

For example, the `settings.json` of a development setup would look like this:
```
{
  "public": {
    "landsOfIllusionsUrl": "http://localhost:3000"
  }
}
```

You run the project by passing in the settings file to `meteor`. I usually create a `run` and `deploy` script in
the root of the project (both are excluded in `.gitignore` since they rely on your particular filesystem).

You must also run the dependant project with the `MONGO_URL` variable set to the address of LOI's MongoDB instance.

And because the LOI server is already running on ports 3000 and 3001, you must start the dependant project on another port.

For example, `run` script can look like:
```
export MONGO_URL=mongodb://localhost:3001/meteor
meteor run --port 3005 --settings /your/path/to/settings.json
```

Instead of `meteor` you then run the project with `./run`.
