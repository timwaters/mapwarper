/*
 * Copyright (C) 2007-2008  Camptocamp
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

/**
 * @requires OpenLayers/Map.js
 * @requires OpenLayers/Control/ModifyFeature.js
 * @requires OpenLayers/Layer/Vector.js
 */

Ext.namespace('mapfish.widgets');

Ext.namespace('mapfish.widgets.editing');

/**
 * Class: mapfish.widgets.editing.FeatureList
 * Use this class to create an editable grid of features.
 *
 * Inherits from:
 * - {Ext.grid.EditorGridPanel}
 */

/**
 * Constructor: mapfish.widgets.editing.FeatureList
 *
 * Parameters:
 * config - {Object} The Grid config.
 */
mapfish.widgets.editing.FeatureList = function(config) {
    Ext.apply(this, config, {
        sm: new Ext.grid.RowSelectionModel({singleSelect: true}),
        clicksToEdit: 1,
        enableDragDrop: true
    });
    mapfish.widgets.editing.FeatureList.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.editing.FeatureList, Ext.grid.EditorGridPanel, {

    /**
     * APIProperty: featureType
     * {Ext.data.Record} Definition of a feature record,
     * created by Ext.data.Record.create()
     */
    featureType: null,

    /**
     * APIProperty: map
     * {<OpenLayers.Map>} Where to display the selected geometries
     */
    map: null,

    /**
     * APIProperty: layer
     * {<OpenLayers.Layer.Vector>} The Vector layer to use to draw the
     * selected geometries.
     */
    layer: null,

    /**
     * APIProperty: automaticMode
     * {Boolean} If true, the geometry to edit can be selected on click.
     * Otherwise, the user has to click on the geometry in the list to
     * put it in edit mode.
     */
    automaticMode: false,

    /**
     * APIProperty: autoFocusMode
     * {Integer} If 0, don't change the visible extent of the map.
     * If 1, change the map's visible extent to match the selected geometry.
     * If 2, make sure the selected geometry is visible (default).
     */
    autoFocusMode: 2,

    /**
     * APIProperty: displayNotEdited
     * {Boolean} If "false", display only the edited feature. If "true", shows
     * the edited features and the others. Only relevant when automaticMode
     * is false.
     */
    displayNotEdited: true,

    /**
     * APIMethod: editGeometryVisual
     * How to represent a geometry in the grid. It will be the thing the user
     * will have to click in order to edit the geometry.
     *
     * Parameters:
     * geometry - {<OpenLayers.Geometry>}
     * record - {<Ext.data.Record>}
     * edited - {Boolean} true if the geometry is being edited on the map.
     */
    editGeometryVisual: function(geometry, record, edited) {
        return geometry ? (edited ? "->" : "X") : "";
    },

    /**
     * Property: isDnd
     * {Boolean} True if we are currently performing a drag and drop. Used
     *      when we receive a "remove" and "add" notification on the store, to
     *      know if it was a drag and drop.
     */
    isDnd: false,

    /**
     * Property: colDefs
     * {Array(Object)} Save the columns parameter (dady nullifies the
     * this.columns property).
     */
    colDefs: null,

    /**
     * Property: modifyFeature
     * {OpenLayers.Control.ModifyFeature} The control used to modify geometries.
     */
    modifyFeature: null,

    /**
     * Method: initComponent
     *      Initialize the component.
     */
    initComponent: function() {
        // sanity checks
        if (!this.map && !this.layer) {
            OpenLayers.Console.error(
                "Mandatory param for FeatureList missing: layer and/or map");
        }
        if (!this.featureType) {
            OpenLayers.Console.error(
                "Mandatory param for FeatureList missing: featureType");
        }

        // keep a reference on the definition of columns
        this.colDefs = this.columns;
        mapfish.widgets.editing.FeatureList.superclass.initComponent.call(this);

        this.setGeoColRenderer();

        // take care of the connections with the map
        if (!this.map) {
            this.map = this.layer.map;
        } else if (!this.layer) {
            this.layer = new OpenLayers.Layer.Vector("Geometry editing");
            this.map.addLayer(this.layer);
        }

        var self = this;

        // define events for "start modifying a geometry", "modifying a geometry",
        // and "done modifying a geometry"
        this.addEvents({geomodifstart: true, geomodif: true, geomodifend: true});

        // create modify feature control
        var mode = OpenLayers.Control.ModifyFeature.RESHAPE |
                   OpenLayers.Control.ModifyFeature.DRAG;
        this.modifyFeature = new OpenLayers.Control.ModifyFeature(this.layer, {
            mode: mode,
            onModificationStart: function(feature) {
                // temporarily activate the modify feature control
                if (!self.automaticMode) {
                    this.activate();
                }
                self.refreshGeometryVisual(feature.data);
                // select and show the row of the feature we are editing
                var record = feature.data;
                var row = self.getStore().findBy(function(r) {
                    return r.id == record.id;
                });
                self.getView().focusCell(row, 0);
                self.getSelectionModel().selectRange(row, row);
                self.fireEvent('geomodifstart', self, record, feature);
            },
            onModification: function(feature) {
                self.fireEvent('geomodif', self, feature.data, feature);
            },
            onModificationEnd: function(feature) {
                // deactivate the modify feature control
                if (!self.automaticMode) {
                    this.deactivate();
                }
                if (feature.data) {
                    self.refreshGeometryVisual(feature.data);
                }
                if (!self.displayNotEdited) {
                    self.layer.removeFeatures(feature);
                }
                self.fireEvent('geomodifend', self, feature.data, feature);
            }
        });
        // add modify feature control to the map
        this.map.addControl(this.modifyFeature);

        // make sure the geometries are removed from the layer if a
        // feature is removed.
        this.getStore().on("remove", function(store, record, index) {
            this.removeGeometries(record);
        }, this);
        this.getStore().on("clear", function(store) {
            store.each(this.removeGeometries, this);
        }, this);

        // add added to the layer if a feature is added.
        function add(store, records, index) {
            if (self.displayNotEdited) {
                for (var i = 0; i < records.length; ++i) {
                    self.addGeometries(records[i]);
                }
            }
            return true;
        }
        this.getStore().on("add", add);
        this.getStore().on("load", function(store, records, options) {
            if (!options.add) {
                // On load, the data was cleared, but no other notification was
                // fired. So we have to do some cleanup. Then, we can add the
                // geometries.
                if (this.modifyFeature.feature) {
                    this.modifyFeature.selectControl.unselect(
                        this.modifyFeature.feature);
                }
                this.clearLayer();
            }
            add(store, records, 0);
            return true;
        }, this);
    },

    /**
     * Method: onRender
     * Called by EXT when the component is rendered.
     */
    onRender: function() {
        mapfish.widgets.editing.FeatureList.superclass.onRender.apply(
            this, arguments);

        // add the possibility to drag and drop rows for re-ordering them
        var self = this;
        var ddrow = new Ext.dd.DropTarget(this.getView().mainBody, {
            ddGroup: 'GridDD',
            notifyOver: function(source, e, data) {
                var cindex = source.getDragData(e).rowIndex;
                if (typeof cindex != "undefined") {
                    return this.dropAllowed;
                }
                return this.dropNotAllowed;
            },
            notifyDrop: function(dd, e, data) {
                var dragData = dd.getDragData(e);
                var destIndex = dragData.rowIndex;
                if (typeof destIndex != "undefined") {
                    var record = data.selections[0];
                    self.isDnd = true;
                    data.grid.store.remove(record);
                    dragData.grid.store.insert(destIndex, record);
                    self.isDnd = false;
                    return true;
                }
                return false;
            }
        });

        // draw the features
        if (this.displayNotEdited) {
            this.drawAllFeatures();
        }
    },

    /**
     * Method: eachGeoColumn
     * Iterate over each columns
     *
     * Parameters:
     * callback - {Function} What to call for each column.
     */
    eachGeoColumn: function(callback) {
        for (var i = 0; i < this.colDefs.length; ++i) {
            var col = this.colDefs[i];
            var colDesc = this.featureType.prototype.fields.get(col.dataIndex);
            if (colDesc.type == 'geo') {
                callback.call(this, col, colDesc, i);
            }
        }
    },

    /**
     * Method: setGeoColRenderer.
     * Sets the renderer to the geometry columns' definition.
     */
    setGeoColRenderer: function() {
        this.eachGeoColumn(function(col, colDesc, colNum) {
            col.renderer = OpenLayers.Function.bind(
                function(value, cellMetaData, record, rowNum, colNum, store) {
                    if (value) {
                        var edited = (this.grid.modifyFeature.feature != null) &&
                                     (this.grid.getFeatureByGeometry(value) ==
                                      this.grid.modifyFeature.feature);
                        return '<div onclick="mapfish.widgets.editing.FeatureList.geometryClickHandler(\''
                            + this.grid.id + '\', ' + record.id + ', \'' + this.colName + '\');">'
                            + this.grid.editGeometryVisual(value, record, edited) + '</div>';
                    } else {
                        return this.grid.editGeometryVisual(value, record, false);
                    }
                }, {grid: this, colName: colDesc.name}
            );
        });
    },

    /**
     * Method: drawAllFeatures
     * Add all the geometries to the vector layer.
     */
    drawAllFeatures: function() {
        this.clearLayer();
        if (this.displayNotEdited) {
            var features = [];
            this.eachGeoColumn(function(col, colDesc, colNum) {
                this.store.each(function (record) {
                    var geometry = record.get(colDesc.name);
                    if (geometry && !this.getFeatureByGeometry(geometry)) {
                        var vector = new OpenLayers.Feature.Vector(
                            geometry, record);
                        features.push(vector);
                    }
                }, this);
            });
            this.layer.addFeatures(features);
        }
    },

    /**
     * Method: addGeometries
     * Add all the geometries of a feature to the vector layer.
     *
     * Parameters:
     * record - {<Ext.data.Record>}
     */
    addGeometries: function(record) {
        var layer = this.layer;
        this.eachGeoColumn(function(col, colDesc, colNum) {
            var geometry = record.get(colDesc.name);
            if (geometry && !this.getFeatureByGeometry(geometry)) {
                var vector = new OpenLayers.Feature.Vector(
                    geometry, record);
                layer.addFeatures(vector);
            }
        });
    },

    /**
     * Method: removeGeometries
     * Remove all the geometries of a feature from the vector layer.
     *
     * Parameters:
     * record - {Ext.data.Record}
     */
    removeGeometries: function(record) {
        this.eachGeoColumn(function(col, colDesc, colNum) {
            var geometry = record.get(colDesc.name);
            if (geometry) {
                var feature = this.getFeatureByGeometry(geometry);
                if (feature) {
                    if (feature == this.modifyFeature.feature) {
                        // not to have bad stuff happening
                        // in modifyFeature.onModificationEnd
                        feature.data = null;
                        this.modifyFeature.selectControl.unselect(feature);
                    }
                    this.layer.removeFeatures([feature]);
                    feature.destroy();
                }
            }
        });
        return true;
    },

    /**
     * Method: getFeatureByGeometry
     * Find the feature in the vector layer in function of the geometry.
     *
     * Parameters:
     * geometry - {<OpenLayers.Geometry>}
     *
     * Returns:
     * {<OpenLayers.Feature.Vector>}
     */
    getFeatureByGeometry: function(geometry) {
        var features = this.layer.features;
        for (var i = 0; i < features.length; ++i) {
            var cur = features[i];
            if (cur.geometry == geometry) {
                return cur;
            }
        }
        return null;
    },

    /**
     * APIMethod: editFirstGeometry
     * Start to edit the first geometry of the given feature.
     * Usefull only if not in automatic mode
     *
     * Parameters:
     * record - {<Ext.data.Record>}
     */
    editFirstGeometry: function(record) {
        if (this.automaticMode) {
            return;
        }
        var colName;
        for (var i = 0; i < this.colDefs.length; ++i) {
            var col = this.colDefs[i];
            var colDesc = this.featureType.prototype.fields.get(col.dataIndex);
            if (colDesc.type == 'geo') {
                colName = colDesc.name;
                break;
            }
        }
        this.editGeometry(record, colName, false);
    },

    /**
     * Method: editGeometry
     * Start to edit one geometry of the given feature.
     *
     * Parameters:
     * record - {Ext.data.Record}
     * colName - {String}
     * focus - {Boolean} If true and in auto-focus mode, will zoom the map on
     *                   the geometry
     */
    editGeometry: function(record, colName, focus) {
        var geometry = record.get(colName);
        if (!geometry){
            return;
        }
        var feature = this.getFeatureByGeometry(geometry);
        if (!feature && !this.displayNotEdited) {
            feature = new OpenLayers.Feature.Vector(
                geometry, record);
            this.layer.addFeatures(feature);
        }
        if (feature) {
            var previousFeature = this.modifyFeature.feature;
            if (previousFeature) {
                this.modifyFeature.selectControl.unselect(
                    this.modifyFeature.feature);
            }
            if (previousFeature != feature) {
                this.modifyFeature.selectControl.select(feature);
                if (focus) {
                    this.manageAutoFocus(geometry);
                }
            }
        } else {
            OpenLayers.Console.error(
                "BUG: cannot find vector feature for: " + record);
        }
    },

    /**
     * Method: manageAutoFocus
     * Change the extent of the map in function of the configuration.
     *
     * Parameters:
     * geometry - {OpenLayers.Geometry}
     */
    manageAutoFocus: function (geometry) {
         if (this.autoFocusMode == 1) {
             this.map.zoomToExtent(geometry.getBounds());
         } else if (this.autoFocusMode == 2) {
             var extent = this.map.getExtent();
             extent.extend(geometry.getBounds());
             var margin = extent.getWidth() * 0.02;
             extent.left += margin;
             extent.right -= margin;
             extent.top -= margin;
             extent.bottom += margin;
             this.map.zoomToExtent(extent);
         }
    },

    /**
     * Method: refreshGeometryVisual
     * Force the refresh of the icon representing the geometry in the grid.
     *
     * Parameters:
     * record - {Ext.data.Record}
     */
    refreshGeometryVisual: function(record) {
        this.getView().refreshRow(record);
    },

    /**
     * APIMethod: setAutomaticMode
     * Change the mode.
     *
     * Parameters:
     * automatic - {Boolean}
     */
    setAutomaticMode: function(automatic) {
        if (automatic == this.automaticMode) {
            return;
        }
        this.automaticMode = automatic;
        if (this.modifyFeature.feature) {
            this.modifyFeature.selectControl.unselect(
                this.modifyFeature.feature);
        }
        if (automatic) {
            this.modifyFeature.activate();
        } else {
            this.modifyFeature.deactivate();
        }
    },

    /**
     * APIMethod: setDisplayNotEdited
     * Change the configuration of what should be displayed.
     *
     * Parameters:
     * value - {Boolean}
     */
    setDisplayNotEdited: function(value) {
        if (value == this.displayNotEdited) {
            return;
        }
        this.displayNotEdited = value;
        if (value) {
            this.drawAllFeatures();
        } else {
            this.clearLayer();
            this.setAutomaticMode(false);
        }
    },

    /**
     * Method: clearLayer
     * Delete all the geometries from the layer with the exception of the
     * currently edited feature (if any) and its handles.
     *
     * Parameters:
     * value - {Boolean}
     */
    clearLayer: function() {
        var toRemove = [];
        var layer = this.layer;
        var edited = this.modifyFeature.feature;
        for (var i = 0; i < layer.features.length; ++i) {
            var cur = layer.features[i];
            if (cur != edited &&
               cur.data && cur.data.endEdit) {
                toRemove.push(cur);
            }
        }
        layer.removeFeatures(toRemove);
    }
});
Ext.reg('featurelist', mapfish.widgets.editing.FeatureList);

/**
 * Method: geometryClickHandler
 * Global function call by the onclick handler of the geometries' icons.
 *
 * Parameters:
 * gridId - {String} ID of the Grid
 * recordId - {String} ID of the record
 * colName - {String} Name of the geometry column
 */
mapfish.widgets.editing.FeatureList.geometryClickHandler = function(
    gridId, recordId, colName) {

    var grid = Ext.getCmp(gridId);
    if (grid) {
        var record = grid.store.getById(recordId);
        if (record) {
            grid.editGeometry(record, colName, true);
        } else {
            OpenLayers.Console.error("Cannot find record with id=" + recordId);
        }
    } else {
        OpenLayers.Console.error("Cannot find grid with id=" + gridId);
    }
};

/**
 * APIMethod: createRecord
 * Generate a Record constructor for a specific record layout and with
 * support for the 'geo' type. This function wraps Ext.data.Record.create.
 *
 * Parameters:
 * cols - {Array} An Array of field definition objects which specify
 *     field names, and optionally, data types, and a mapping for an
 *     Ext.data.Reader to extract the field's value from a data
 *     object. For further information see the Ext API reference
 *     (Ext.data.Record.create).
 *
 * Returns
 * {Function} - Record constructor
 */
mapfish.widgets.editing.FeatureList.createRecord = function(cols) {
    for (var i = 0; i < cols.length; ++i) {
        var col = cols[i];
        if (col.type == 'geo') {
            if (!col.convert) {
                col.convert = function(v) {
                    return v;
                };
            }
            if (!col.sortType) {
                col.sortType = Ext.data.SortTypes.none();
            }
        }
    }
    return Ext.data.Record.create.apply(null, arguments);
};
