/* eslint-disable no-unused-vars */
import process from 'process';
import { app, screen } from 'electron';
import fs from 'fs';
import path from 'path';

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
            const getMaxWindowContentSize = () => {
                const display = screen.getDisplayMatching(window.getBounds());
                const windowBounds = window.getBounds();
                const contentBounds = window.getContentBounds();

                // Reserve space for the native window frame so the resized content fits inside the display work area.
                const frameWidth = windowBounds.width - contentBounds.width;
                const frameHeight = windowBounds.height - contentBounds.height;

                return {
                    width: Math.max(1, display.workArea.width - frameWidth),
                    height: Math.max(1, display.workArea.height - frameHeight)
                };
            };

            const sendMaxWindowContentSize = () => {
                windowModule.send('maxWindowContentSize', getMaxWindowContentSize());
            };

            windowModule.on('isFullscreen', () => {
                this.log.verbose('isFullscreen received');
                windowModule.send('isFullscreen', window.isFullScreen());
            });

            windowModule.on('setFullscreen', (event, fullscreen) => {
                this.log.verbose('setFullscreen received');
                window.setFullScreen(fullscreen);
            });

            windowModule.on('getMaxWindowContentSize', () => {
                this.log.verbose('getMaxWindowContentSize received');
                sendMaxWindowContentSize();
            });

            windowModule.on('resizeToMaxViewport', (event, maxViewportSize) => {
                this.log.verbose('resizeToMaxViewport received');

                // Ignore malformed requests and fullscreen transitions, where Electron owns the window size.
                if (!maxViewportSize || !Number.isFinite(maxViewportSize.width)
                    || !Number.isFinite(maxViewportSize.height) || window.isFullScreen()) {
                    return;
                }

                // Restore a maximized window before applying an explicit viewport size.
                if (window.isMaximized()) {
                    window.unmaximize();
                }

                const display = screen.getDisplayMatching(window.getBounds());
                const maxWindowContentSize = getMaxWindowContentSize();
                const targetContentSize = {
                    width: Math.max(
                        1,
                        Math.min(Math.round(maxViewportSize.width), maxWindowContentSize.width)
                    ),
                    height: Math.max(
                        1,
                        Math.min(Math.round(maxViewportSize.height), maxWindowContentSize.height)
                    )
                };

                window.setContentSize(targetContentSize.width, targetContentSize.height);

                // Center the resized window in the work area of the display it was already occupying.
                const resizedWindowBounds = window.getBounds();
                const targetWindowPosition = {
                    x: Math.round(display.workArea.x + (display.workArea.width - resizedWindowBounds.width) / 2),
                    y: Math.round(display.workArea.y + (display.workArea.height - resizedWindowBounds.height) / 2)
                };

                window.setPosition(targetWindowPosition.x, targetWindowPosition.y);
            });

            // Report fullscreen events to our meteor app.
            window.on('enter-full-screen', () => {
                windowModule.send('isFullscreen', true);
            });

            window.on('leave-full-screen', () => {
                windowModule.send('isFullscreen', false);
                sendMaxWindowContentSize();
            });

            // Update scale availability when the window moves to a display with a different resolution.
            window.on('move', sendMaxWindowContentSize);

            const onDisplayMetricsChanged = () => {
                sendMaxWindowContentSize();
            };

            screen.on('display-metrics-changed', onDisplayMetricsChanged);

            window.on('closed', () => {
                screen.removeListener('display-metrics-changed', onDisplayMetricsChanged);
            });

            window.webContents.setWindowOpenHandler(({ url }) => {
                this.log.verbose('Prevented opening a second window.');
                windowModule.send('goToUrl', url);
                return { action: 'deny' };
            });
        });
    }
}

app.on('will-quit', () => {
    try {
        fs.rmSync(path.join(app.getAppPath(), '.reify-cache'), {
            recursive: true,
            force: true
        });
    } catch (error) {
        console.error('Reify cache cleanup failed.', error);
    }
});
