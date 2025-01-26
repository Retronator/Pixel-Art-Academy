/* eslint-disable no-unused-vars */
import process from 'process';
import { app, dialog } from 'electron';

/**
 * Entry point to your native desktop code.
 *
 * @class
 */
export default class Desktop {
    /**
     * @param {Object} log         - Winston logger instance
     * @param {Object} skeletonApp - reference to the skeleton app instance
     * @param {Object} appSettings - settings.json contents
     * @param {Object} eventsBus   - event emitter for listening or emitting events
     *                               shared across skeleton app and every module/plugin
     * @param {Object} modules     - references to all loaded modules
     * @param {Object} Module      - reference to the Module class
     * @constructor
     */
    constructor({
        log, skeletonApp, appSettings, eventsBus, modules, Module
    }) {
        this.log = log;

        // Remove the default exception handler.
        skeletonApp.removeUncaughtExceptionListener();

        // Handle main messages.
        const desktopModule = new Module('desktop');

        desktopModule.on('closeApp', () => {
            this.log.verbose('closeApp received');
            app.quit()
        });

        desktopModule.on('getProcessPlatform', (event, fetchId) => {
            this.log.verbose('getPlatform received');
            desktopModule.respond('getProcessPlatform', fetchId, process.platform);
        });

        // Handle window messages.
        const windowModule = new Module('window');

        eventsBus.on('windowCreated', (window) => {
            windowModule.on('isFullscreen', () => {
                this.log.verbose('isFullscreen received');
                windowModule.send('isFullscreen', window.isFullScreen());
            });

            windowModule.on('setFullscreen', (event, fullscreen) => {
                this.log.verbose('setFullscreen received');
                window.setFullScreen(fullscreen);
            });

            // Report fullscreen events to our meteor app.
            window.on('enter-full-screen', () => {
                windowModule.send('isFullscreen', true);
            });

            window.on('leave-full-screen', () => {
                windowModule.send('isFullscreen', false);
            });
        });
    }
}
