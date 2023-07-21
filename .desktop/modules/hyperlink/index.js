import moduleJson from './module.json';
import { shell } from 'electron';

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
export default class Hyperlink {
  constructor({log, skeletonApp, appSettings, eventsBus, modules, settings, Module}) {
    this.module = new Module(moduleJson.name);

    // Get the automatically predefined logger instance.
    this.log = log;
    this.eventsBus = eventsBus;

    this.module.on('open', (event, fetchId, url) => {
      this.log.verbose('open hyperlink received', url);

      shell.openExternal(url).then(() => {
        this.module.respond('open', fetchId, null);
      }).catch((error) => {
        this.module.respond('open', fetchId, error);
      });
    });
  }
}
