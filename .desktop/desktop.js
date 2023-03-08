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

        const desktopModule = new Module('desktop');
        const windowModule = new Module('window');

        // From Meteor use this by invoking Desktop.send('desktop', 'closeApp');
        desktopModule.on('closeApp', () => app.quit());

        desktopModule.on('getProcessPlatform', (event, fetchId) => {
            this.log.verbose('getPlatform received');
            desktopModule.respond('getProcessPlatform', fetchId, process.platform);
        });

        // We need to handle gracefully potential problems.
        // Let's remove the default handler and replace it with ours.
        skeletonApp.removeUncaughtExceptionListener();

        process.on('uncaughtException', Desktop.uncaughtExceptionHandler);

        // Chrome problems should also be handled. The `windowCreated` event has a `window`
        // reference. This is the reference to the current Electron renderer process (Chrome)
        // displaying your Meteor app.
        eventsBus.on('windowCreated', (window) => {
            window.webContents.on('render-process-gone', Desktop.windowRenderProcessGoneHandler);
            window.on('unresponsive', Desktop.windowUnresponsiveHandler);

            window.on('enter-full-screen', () => {
                windowModule.send('isFullscreen', window.isFullScreen());
            });

            window.on('leave-full-screen', () => {
                windowModule.send('isFullscreen', window.isFullScreen());
            });

            windowModule.on('isFullscreen', () => {
                this.log.verbose('isFullscreen received');
                windowModule.send('isFullscreen', window.isFullScreen());
            });

            windowModule.on('setFullscreen', (event, fullscreen) => {
                this.log.verbose('setFullscreen received');
                window.setFullScreen(fullscreen);
            });
        });

        // Consider setting a crash reporter ->
        // https://github.com/electron/electron/blob/master/docs/api/crash-reporter.md
    }

    /**
     * Window crash handler.
     */
    static windowRenderProcessGoneHandler(error) {
        Desktop.displayRestartDialog(
            'Application render process is gone',
            'Do you want to restart it?',
            error.reason
        );
    }

    /**
     * Window's unresponsiveness handler.
     */
    static windowUnresponsiveHandler() {
        Desktop.displayRestartDialog(
            'Application is not responding',
            'Do you want to restart it?'
        );
    }

    /**
     * JS's uncaught exception handler.
     * @param {string} error - error message
     */
    static uncaughtExceptionHandler(error) {
        // Consider sending a log somewhere, it is good be aware your users are having problems,
        // right?
        Desktop.displayRestartDialog(
            'Application encountered an error',
            'Do you want to restart it?',
            error.message
        );
    }

    /**
     * Displays an error dialog with simple 'restart' or 'shutdown' choice.
     * @param {string} title   - title of the dialog
     * @param {string} message - message shown in the dialog
     * @param {string} details - additional details to be displayed
     */
    static displayRestartDialog(title, message, details = '') {
        dialog.showMessageBox(
            {
                type: 'error', buttons: ['Restart', 'Shutdown'], title, message, detail: details
            },
            (response) => {
                if (response === 0) {
                    app.relaunch();
                }
                app.exit(0);
            }
        );
    }
}
