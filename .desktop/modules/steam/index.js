import moduleJson from './module.json';
import { shell } from 'electron';

const steamworks = require('steamworks.js')

/**
 * @param {Object} log         - Winston logger instance
 * @param {Object} skeletonApp - reference to the skeleton app instance
 * @param {Object} appSettings - settings.json contents
 * @param {Object} eventsBus   - event emitter for listening or emitting events
 *                               shared across skeleton app and every module/plugin
 * @param {Object} modules     - references to all loaded modules
 * @param {Object} settings    - module settings
 * @param {Object} Module      - reference to the Module class
 * @constructor
 */
export default class Steam {
  constructor({log, skeletonApp, appSettings, eventsBus, modules, settings, Module}) {
    this.module = new Module(moduleJson.name);

    // Get the automatically predefined logger instance.
    this.log = log;
    this.eventsBus = eventsBus;

    this.module.on('initialize', (event, fetchId, appId) => {
      this.log.verbose('initialize received', appId);

      try {
        // Start the Steam client.
        this.client = steamworks.init(appId);
        this.log.verbose('Steam client initialized.');

        const steamData = {
          apps: {
            isSubscribed: this.client.apps.isSubscribed(),
            appBuildId: this.client.apps.appBuildId(),
            appOwner: this.client.apps.appOwner(),
            availableGameLanguages: this.client.apps.availableGameLanguages(),
            currentGameLanguage: this.client.apps.currentGameLanguage(),
            currentBetaName: this.client.apps.currentBetaName()
          },
          cloud: {
            isEnabledForAccount: this.client.cloud.isEnabledForAccount(),
            isEnabledForApp: this.client.cloud.isEnabledForApp()
          },
          localPlayer: {
            steamId: this.client.localplayer.getSteamId(),
            name: this.client.localplayer.getName(),
            level: this.client.localplayer.getLevel(),
            ipCountry: this.client.localplayer.getIpCountry()
          },
          utils: {
            appId: this.client.utils.getAppId(),
            isSteamRunningOnSteamDeck: this.client.utils.isSteamRunningOnSteamDeck()
          }
        }

        this.module.respond('initialize', fetchId, steamData);
      } catch (error) {
        this.log.verbose('Steam client not available.', error.message);
        this.module.respond('initialize', fetchId, null);
      }
    });

    this.module.on('setEnabledForApp', (event, fetchId, enabled) => {
      this.log.verbose('setEnabledForApp received');
      if (this.respondIfUnavailable('setEnabledForApp', fetchId)) return;

      try {
        this.client.steam.setEnabledForApp(enabled);

        const isEnabledForApp = this.client.cloud.isEnabledForApp()
        this.module.respond('setEnabledForApp', fetchId, isEnabledForApp);
      } catch (error) {
        this.log.verbose('setEnabledForApp encountered an error.', error.message);
        this.module.respond('setEnabledForApp', fetchId, null);
      }
    });
  }

  respondIfUnavailable(methodName, fetchId) {
    if (!this.client) {
      this.log.verbose('Steam client not available.');
      this.module.respond(methodName, fetchId, null);
      return true;
    }
    return false;
  }
}
