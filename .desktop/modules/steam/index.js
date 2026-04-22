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

    // Enable Steam overlay.
    steamworks.electronEnableSteamOverlay();

    try {
      // Start the Steam client.
      this.client = steamworks.init(2330360);
      this.log.verbose('Steam client initialized.');
    }
    catch (e) {
      this.log.verbose('Steam client not available.');
    }

    this.module.on('getLocalPlayer', (event, fetchId) => {
      this.log.verbose('getLocalPlayer received');
      if (this.respondIfUnavailable('getLocalPlayer', fetchId)) return;

      const localPlayer = {
        id: this.client.localplayer.getSteamId(),
        name: this.client.localplayer.getName(),
        level: this.client.localplayer.getLevel(),
        country: this.client.localplayer.getIpCountry()
      }

      this.log.verbose('Local player retrieved', localPlayer.name);
      this.module.respond('getLocalPlayer', fetchId, localPlayer);
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
