# Pixel Art Academy

An adventure game for learning how to draw.

Current live version: [pixelart.academy](https://pixelart.academy)

## Running

Install [Meteor](https://www.meteor.com):

```
curl https://install.meteor.com/ | sh
```

Checkout and update:

```
meteor update
meteor update --all-packages
```

Run with:

```
meteor
```

## Advanced setup 

If you want to configure extra features such as logging in with 
additional services, you will want to include a settings file.

You will also want to run on a custom domain that you set to your
localhost IP in the `/etc/hosts` file.

```
127.0.0.1       localhost.pixelart.academy
```

Then you can create a shell script to run the project with:

```
./run
```

contents of `run`:

```
export ROOT_URL=http://localhost.pixelart.academy:3000
meteor run --settings path/to/settings.json
```

contents of `settings.json`:

```
{
  "test": true,
  "admin":{
    "username":"admin",
    "password":"test",
    "email":"admin@test.com",
    "profile":{
      "name": "Administrator"
    }
  },
  "oauthSecretKey": "1234567890",
  "facebook": {
    "appId": "1234567890",
    "secret": "1234567890"
  },
  "twitter": {
    "consumerKey": "1234567890",
    "secret": "1234567890"
  },
  "google": {
    "clientId": "1234567890",
    "secret": "1234567890"
  },
  "amazonWebServices": {
    "accessKey": "1234567890",
    "secret": "1234567890"
  },
  "stripe": {
    "secretKey": "1234567890"
  },
  "public": {
    "stripe": {
      "publishableKey": "1234567890"
    },
    "google": {
      "analytics": "1234567890"
    }
  }
}
```

### Settings keys

private section:

| Key                  | Description                                                                |
|----------------------|----------------------------------------------------------------------------|
| test                 | Creates test users with different backer levels.                           |
| admin                | Creates an admin user with given login info.                               |
| oauthSecretKey       | Enables encryption of login services tokens.                               |
| facebook             | Enables logging in with Facebook.                                          |
| twitter              | Enables logging in with Twitter.                                           |
| google               | Enables logging in with Google.                                            |
| amazonWebServices    | Enables upload of artworks.                                                |
| stripe               | Enables Stripe payments (server side).                                     |

Public section:

| Key                  | Description                                                                |
|----------------------|----------------------------------------------------------------------------|
| stripe               | Enables Stripe payments (client side).                                     |
| google.analytics     | Enables Google Analytics.                                                  |
