/*
 * Copyright (C) 2008 Camptocamp
 *
 * This file is part of MapFish Client
 *
 * MapFish Client is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish Client is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MapFish Client.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * @requires OpenLayers/Events.js
 */

/*
 * TODO: support for automatic offline/online detection with network polling
 */

/*
 * Class: mapfish.Offline
 * MapFish Offline core component.
 * This object is a singleton, it can't be instanciated.
 * This API is inspired by The Dojo Offline Toolkit, created by
 * Dojo, SitePen, and Brad Neuberg.
 */
mapfish.Offline = function() {

    /**
     * Supported offline event types:
     *  - *network* triggered when the browser changes from online to offline
     *      state of vice-versa.  Listeners will receive an event with a string
     *      parameter "online" if we went online, or "offline" if we went
     *      offline
     *  - *sync* triggered when a syncing operation can be performed.  Listeners
     *      are called with a string parameter "download" when a data should be
     *      synchronized from server to client or "upload" for the reverse.
     *      When the syncing operations are finished, listeners are called
     *      with a string parameter "downloadDone" or "uploadDone" for end of
     *      download or upload respectively.
     *  - *synctask* triggered when a sync task is added or is
     *      finished.  The listener is called with an object contains the
     *      properties:
     *       - type: can be "syncTaskAdded" or "syncTaskDone" if the task
     *               was added or is done
     *       - syncTask: a SyncTask object, containing the "label" and "id"
     *               properties for the task label or task identifier
     *               respectively
     */
    var EVENT_TYPES = ["network", "sync", "synctask"];

    // private variables and functions

    var syncTaskCounter = 0;
    var numActiveSyncTasks = 0;
    var activeSyncTaskIds = {};

    function SyncTask(label, id) {
        this.label = label;
        this.id = id;
    }

    function setOnline() {
        this.isOnline = true;
        this.events.triggerEvent("network", "online");
    }

    function setOffline() {
        this.isOnline = false;
        this.events.triggerEvent("network", "offline");
    }

    function maybeNotifySyncDone() {
        if (numActiveSyncTasks > 0 || this.syncState == null)
            return;

        this.isSynchronizing = false;
        if (this.syncState == "download") {
            setOffline.call(this);
            this.events.triggerEvent("sync", "downloadDone");
        } else if (this.syncState == "upload") {
            this.events.triggerEvent("sync", "uploadDone");
        } else {
            OpenLayers.Console.error("Unexpected state " + this.syncState);
        }
        this.syncState = null;
    }

    // public object

    var off =  {

    /**
     * Property: isOnline
     * {Boolean} - true if we are online, false if not.
     */
    isOnline: true,

    /**
     * Property: syncState
     * {String} - Synchronizing state, can be "download", "offline" or null if
     *            not currently synchronizing.
     */
    syncState: null,

    /**
     * APIProperty: hasOfflineCache
     * {Boolean} - Determines if an offline cache is available or installed.
     */
    hasOfflineCache: false,

    /**
     * APIProperty: events
     * {<OpenLayers.Events>} An events object that handles all offline events.
     */
    events: null,

    /**
     * APIMethod: goOffline
     * Manually goes offline, away from the network.
     */
    goOffline: function() {
        if (!this.isOnline)
            return;

        this.syncState = "download";
        this.events.triggerEvent("sync", "download");

        // Wait a bit before checking if sync tasks have been added
        var self = this;
        setTimeout(function() {
            maybeNotifySyncDone.call(self);
        }, 100);
    },

    /**
     * APIMethod: goOnline
     * Attempts to go online.
     */
    goOnline: function() {
        if (this.isOnline)
            return;
        // TODO: do a XHR request to check if we are really online

        setOnline.call(this);

        this.syncState = "upload";
        this.events.triggerEvent("sync", "upload");

        // Wait a bit before checking if sync tasks have been added
        var self = this;
        setTimeout(function() {
            maybeNotifySyncDone.call(self);
        }, 100);
    },

    /**
     * APIMethod: addSyncTask
     * Informs the component that a sync operation is pending. This
     * method will return a task identifier. You need to call the syncTaskDone()
     * method when the sync operation is finished.
     *
     * Parameters:
     * label - {String} The sync task label. This could be used in a
     *         widget to display the sync status.
     *
     * Returns:
     * {Integer} Sync task identifier. This should be given back to
     *           the syncTaskDone() method. Clients shouldn't try to interpret
     *           this returned value.
     */
    addSyncTask: function(label) {
        numActiveSyncTasks++;
        var syncTaskId = ++syncTaskCounter;
        var syncTask = new SyncTask(label, syncTaskId);
        activeSyncTaskIds[syncTaskId] = syncTask;

        this.events.triggerEvent("synctask", {type: "syncTaskAdded",
                                              syncTask: syncTask});

        return syncTaskId;
    },

    /**
     * APIMethod: syncTaskDone
     * When a synchronizing task created by addSyncTask() is finished, this
     * method must be called with the given identifier.
     *
     * Parameters:
     * syncTaskId - {Integer} synchronization task identifier, as returned by
     *              the addSyncTask() method.
     */
    syncTaskDone: function(syncTaskId) {
        if (!activeSyncTaskIds[syncTaskId]) {
            OpenLayers.Console.error(arguments.callee.name +
                                     ": Unknown syncTaskId " + syncTaskId);
            return;
        }
        this.events.triggerEvent("synctask",
                                 {type: "syncTaskDone",
                                  syncTask: activeSyncTaskIds[syncTaskId]});
        numActiveSyncTasks--;
        delete activeSyncTaskIds[syncTaskId];
        
        // Wait a bit before checking if sync tasks have been added
        var self = this;
        setTimeout(function() {
            maybeNotifySyncDone.call(self);
        }, 0);
    }

    };

    // Initialization

    off.events = new OpenLayers.Events(this, null, EVENT_TYPES,
                                       false);

    if (navigator && navigator.onLine != undefined) {
        off.isOnline = navigator.onLine;
    }

    // FIXME: not accurate if gears_init.js is loaded after Offline.js
    off.hasOfflineCache = !!(window.google && google.gears);

    return off;
}();
