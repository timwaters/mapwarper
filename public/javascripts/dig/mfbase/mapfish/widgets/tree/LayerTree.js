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
 * @requires OpenLayers/Layer/WMS.js
 * @requires OpenLayers/Layer/WMS/Untiled.js
 * @requires OpenLayers/Layer/MapServer.js
 */

Ext.namespace('mapfish.widgets');

/*
 * Extends Ext TreeNodeUI to display radio buttons.
 */
mapfish.widgets.RadioTreeNodeUI = Ext.extend(Ext.tree.TreeNodeUI, {

    // Unfortunately, IE does not support changing the type attribute of the form
    // so we need to duplicate the whole method here. Please keep this in sync
    // with the one from Ext in case of update. The change from Ext is to use
    // a type="radio" with a "name" attribute on the form.
    renderElements : function(n, a, targetNode, bulkRender){
        this.indentMarkup = n.parentNode ? n.parentNode.ui.getChildIndent() : '';

        var cb = typeof a.checked == 'boolean';
        var radioGrp = n.attributes.radioGrp || "radioGrp";

        var href = a.href ? a.href : Ext.isGecko ? "" : "#";
        var buf = ['<li class="x-tree-node"><div ext:tree-node-id="',n.id,'" class="x-tree-node-el x-tree-node-leaf x-unselectable ', a.cls,'" unselectable="on">',
            '<span class="x-tree-node-indent">',this.indentMarkup,"</span>",
            '<img src="', this.emptyIcon, '" class="x-tree-ec-icon x-tree-elbow" />',
            '<img src="', a.icon || this.emptyIcon, '" class="x-tree-node-icon',(a.icon ? " x-tree-node-inline-icon" : ""),(a.iconCls ? " "+a.iconCls : ""),'" unselectable="on" />',
            cb ? ('<input class="x-tree-node-cb" type="radio" id="'+ n.id + '" name="' + radioGrp + '" ' + (a.checked ? 'checked="checked" />' : '/>')) : '',
            '<a hidefocus="on" class="x-tree-node-anchor" href="',href,'" tabIndex="1" ',
             a.hrefTarget ? ' target="'+a.hrefTarget+'"' : "", '><span unselectable="on">',n.text,"</span></a></div>",
            '<ul class="x-tree-node-ct" style="display:none;"></ul>',
            "</li>"].join('');

        var nel;
        if(bulkRender !== true && n.nextSibling && (nel = n.nextSibling.ui.getEl())){
            this.wrap = Ext.DomHelper.insertHtml("beforeBegin", nel, buf);
        }else{
            this.wrap = Ext.DomHelper.insertHtml("beforeEnd", targetNode, buf);
        }

        this.elNode = this.wrap.childNodes[0];
        this.ctNode = this.wrap.childNodes[1];
        var cs = this.elNode.childNodes;
        this.indentNode = cs[0];
        this.ecNode = cs[1];
        this.iconNode = cs[2];
        var index = 3;
        if(cb){
            this.checkbox = cs[3];
            index++;
        }
        this.anchor = cs[index];
        this.textNode = cs[index].firstChild;
    },

    // Version of renderElements we could use if IE wasn't so fucked up
    _unused_renderElements : function(n, a, targetNode, bulkRender){
        mapfish.widgets.RadioTreeNodeUI.superclass.renderElements
                                                  .apply(this, arguments);
        var cbNode = Ext.DomQuery.selectNode(".x-tree-node-cb", this.elNode);
        var radioGrp =  n.attributes.radioGrp || "radioGrp";
        cbNode.setAttribute("type", "radio");
        cbNode.setAttribute("id",  n.id);
        cbNode.setAttribute("name", radioGrp);
    },

    // private
    onRadioChange : function(){
        var checked = this.checkbox.checked;
        this.node.attributes.checked = checked;
        this.fireEvent('radiochange', this.node, checked);
    }
});

/*
 * Extends Ext TreeEventModel to handle radio button events.
 */
mapfish.widgets.LayerTreeEventModel = Ext.extend(Ext.tree.TreeEventModel, {

    delegateClick : function(e, t){
        if(!this.beforeEvent(e)){
            return;
        }

        if(e.getTarget('input[type=checkbox]', 1)){
            this.onCheckboxClick(e, this.getNode(e));
        }
        else if(e.getTarget('input[type=radio]', 1)){
            this.onRadioClick(e, this.getNode(e));
        }
        else if(e.getTarget('.x-tree-ec-icon', 1)){
            this.onIconClick(e, this.getNode(e));
        }
        else if(this.getNodeTarget(e)){
            this.onNodeClick(e, this.getNode(e));
        }
    },

    onRadioClick: function(e, node){
        if (!node.ui.onRadioChange) {
            OpenLayers.Console.error("Invalid TreeNodeUI Class, no " +
                                     "onRadioChange is available");
            return;
        }
        node.ui.onRadioChange(e);
    }
});


/**
 * Class: mapfish.widgets.LayerTree
 * Extension of Ext TreePanel to show a tree that can control OpenLayers layers.
 *
 * Inherits from:
 * - {Ext.tree.TreePanel}
 */

/**
 * Constructor: mapfish.widgets.LayerTree
 *
 * Parameters:
 * config - {Object} Config object
 */
mapfish.widgets.LayerTree = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.LayerTree.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.LayerTree, Ext.tree.TreePanel, {

    /**
     * APIProperty: separator
     * {String} the separator character to use in between layer name and sublayer.
     */
    separator: ":",

    /**
     * APIProperty: model
     * {Array(Object)} Hierarchical structure to build the tree.
     * Here's an example:
     * (start code)
     *
     *          [
     *              {
     *                  text: 'Background layers',
     *                  expanded: true,
     *                  children: [
     *                      {
     *                          text: 'OpenLayers WMS',
     *                          icon: 'http://www.openlayers.org/favicon.ico',
     *                          layerNames: ['OpenLayers WMS'],
     *                          checked: true
     *                      },
     *                      {
     *                          text: 'OpenAerialMap WMS',
     *                          layerNames: ['OpenAerialMap'],
     *                          checked: false
     *                      }
     *                  ]
     *              },
     *              {
     *                  text: 'Overlay layers',
     *                  checked: false,
     *                  children: [
     *                      {
     *                          text: 'OpenStreetMap WMS',
     *                          icon: 'http://www.openstreetmap.org/favicon.ico',
     *                          layerNames: ['OpenStreetMap'],
     *                          checked: false
     *                      }
     *                  ]
     *              }
     *          ];
     * (end)
     * Each node can contain the following properties:
     * text: {String} The label to show in the tree
     * checked: {Boolean} checkbox status. If this property is not set (undefined),
     *          no checkbox is drawn. It is important to note that the checkbox
     *          status takes precedence over the state defined in the OL layer.
     * icon: {String} Optional image URL to show as an icon.
     * expanded: {Boolean} True of this node should be expanded at startup. Default
     *           is to have node collapsed.
     * layerNames: {Array(String)} Array of OpenLayer layer names to associate
     *             with this node. If you are using a layer which can use
     *             sublayers (WMS or Mapserver), it is possible to use a specific
     *             syntax: <OL layer name> + separator + <sublayer identifier>.
     *             The default separator is ":", which can be changed in the
     *             LayerTree.separator property if it conflicts. For instance:
     *             MyWMS:roads
     *
     * Other properties are passed to Ext. For instance the "cls" property can
     * be used to set a specific class on the node.
     */
    model: null,

    /**
     * APIProperty: showWmsLegend
     * {Boolean} This is only used when no model is specified (when the model
     * is automatically extracted from the map layers). If true, the model
     * will show legend icons for WMS layers.
     */
    showWmsLegend: false,

    /**
     * Property: rootVisible
     * Overridden, see {Ext.tree.TreePanel}
     */
    rootVisible: false,

    /**
     * Property: animate
     * Overridden, see {Ext.tree.TreePanel}
     */
    animate: true,

    /**
     * Property: autoScroll
     * Overridden, see {Ext.tree.TreePanel}
     */
    autoScroll: true,

    /**
     * Property: loader
     * Overridden, see {Ext.tree.TreePanel}
     */
    loader: new Ext.tree.TreeLoader({}),

    /**
     * Property: enableDD
     * Overridden, see {Ext.tree.TreePanel}
     */
    enableDD: false,

    /**
     * Property: containerScroll
     * Overridden, see {Ext.tree.TreePanel}
     */
    containerScroll: true,

    /**
     * APIProperty: ascending
     * If true and using automatic model, the layers in the tree will show the
     * bottom OpenLayer layer on top and the top OpenLayer layer on the
     * bottom. If false, this is inverted.
     */
    ascending: true,

    /**
     * Property: _automaticModel
     * Set to false automatically if a model is given. Should not be manually
     * overridden
     */
    _automaticModel: true,

    // The instance variables below are cache objects used for faster access
    // to objects and properties. If the model or one of the map layer changes,
    // the method updateCachedObjects() has to be called to refresh them.

    /**
     * Property: layerNameToLayer
     * {Object} Map of {String} layer name to {<OpenLayers.Layer>}
     */
    layerNameToLayer: {},
    /**
     * Property: baseLayerNames
     * {Array(String)} List of base layer names
     */
    baseLayerNames: [],
    /**
     * Property: layersWithSublayers
     * {Object} Map of {String} layer name to {Boolean}. Contains as keys the
     *          name of layers which are using sublayers
     */
    layersWithSublayers: {},
    /**
     * Property: layerToNodeIds
     * {Object} Map of {String} layer name to {String} node identifiers. The
     * layer names may contain sublayers in the format
     * <layer name:sublayer name>.
     */
    layerToNodeIds: {},
    /**
     * Property: nodeIdToNode
     * Note: this.getNodeById can't be used because it only contains nodes
     * which have been generated in the DOM, and we can get called before
     * the DOM is generated. This variable is used to do the mapping ourself.
     *
     * {Object} Map of {String} node identifiers to {Ext.tree.TreeNode} objects.
     */
    nodeIdToNode: {},

    /**
     * Property: nodeIdToLayers
     * {Object} Map of {String} node identifiers to {<OpenLayers.Layer>} objects.
     */
    nodeIdToLayers: {},

    /**
     * Method: hasCheckbox
     * Returns whether a Node has a checkbox attached to it
     *
     * Parameters:
     * node - {Ext.data.Node} node to query
     *
     * Returns:
     * {Boolean} True if the node has a checkbox
     */
    hasCheckbox: function (node) {
        return typeof(node.attributes.checked) == "boolean";
    },

    /**
     * APIMethod: setNodeChecked
     * Sets the checked status on a node.
     *
     * Parameters:
     * nodeOrId - {String} node id or {Ext.data.Node} to set the checked status.
     * checked - {Boolean} checked status to set.
     *           If not set, this method toggles the current checkbox state.
     * fireEvent - {Boolean} whether to fire the 'checkchange' event or not
     *             (which updates the tree). Defaults to true.
     */
    setNodeChecked: function(nodeOrId, checked, fireEvent) {
        var node = (nodeOrId instanceof Ext.data.Node) ?
            nodeOrId : this.getNodeById(nodeOrId);

        if (!node || !this.hasCheckbox(node)) {
            return;
        }

        if (checked === undefined) {
            checked = !node.attributes.checked;
        }

        // update model
        node.attributes.checked = checked;

        // sync ui
        if (node.ui && node.ui.checkbox) {
            node.ui.checkbox.checked = checked;
        }

        // fire event if required
        if (fireEvent || (fireEvent === undefined))  {
            node.fireEvent('checkchange', node, checked);
        }
    },

    /**
     * Method: _updateCachedObjects
     * Refreshes the cached objects from the model and OpenLayers map. See the
     * list of updated variables and their meaning in the list of properties
     * above.
     */
    _updateCachedObjects: function() {

        if (!this.map) {
            OpenLayers.Console.error("map Object needs to be available when " +
                                     "calling _updateCachedObjects");
            return;
        }

        // Reset objects
        this.layerNameToLayer = {};
        this.baseLayerNames = [];
        this.layersWithSublayers = {};
        this.layerToNodeIds = {};
        this.nodeIdToNode = {};
        this.nodeIdToLayers = {};

        // Fills layerNameToLayer and baseLayerNames
        Ext.each(this.map.layers, function(layer) {
            var name = layer.name;
            this.layerNameToLayer[name] = layer;

            if (layer.isBaseLayer)
                this.baseLayerNames.push(name);
        }, this);

        // Fills layersWithSublayers and nodeIdToLayers
        this.getRootNode().cascade(function(node) {
            if (!node.attributes.layerNames)
                return true;
            var layerNames = node.attributes.layerNames;

            for (var i = 0; i < layerNames.length; i++) {
                var name = layerNames[i];
                if (name.indexOf(this.separator) != -1) {
                    var name = name.split(this.separator)[0];
                    this.layersWithSublayers[name] = true;
                }
                if (!this.nodeIdToLayers[node.id])
                    this.nodeIdToLayers[node.id] = [];
                this.nodeIdToLayers[node.id].push(this.layerNameToLayer[name]);
            }
        }, this);

        // Fills layerToNodeIds and nodeIdToNode
        this.getRootNode().cascade(function(node) {
            var checked = node.attributes.checked;

            var layerNames = node.attributes.layerNames;
            if (!layerNames)
                return;

            for (var i = 0; i < layerNames.length; i++) {
                var layerName = layerNames[i];
                if (!layerName)
                    continue;

                if (!this.layerToNodeIds[layerName])
                    this.layerToNodeIds[layerName] = [];
                this.layerToNodeIds[layerName].push(node.id);
                this.nodeIdToNode[node.id] = node;
            }
        }, this);
    },

    /**
     * Method: _updateCheckboxAncestors
     * This method walks the tree, and checks or unchecks nodes to match the
     * constraints:
     * If all child checkboxes are checked, the parent should be checked.
     * If one child checkbox is not checked, parent should not be checked.
     */
    _updateCheckboxAncestors: function() {

        // Map of all the node ids not yet visited by updateNodeCheckbox
        var unvisitedNodeIds = {};
        var tree = this;

        //
        // This function updates the node checkbox according to the status of
        // the descendants. It must be called on a node checkbox nodes only.
        //
        // It is called recursively and returns a boolean:
        // - If the node has no children checkboxes, the status of the checkbox
        //   is returned
        // - Otherwise, it returns true if all the children witch checkbox are
        //   checked or false in the other case.
        //
        // As a side effect, it will update the checkbox state of the node, and
        //  remove visited node ids from the unvisitedNodeIds variable, to
        //  prevent visiting nodes multiple times.
        function updateNodeCheckbox(node) {
            if (!tree.hasCheckbox(node)) {
                throw new Error(arguments.callee.name +
                                " should only be called on checkbox nodes");
            }

            var checkboxChildren = [];
            node.eachChild(function(child) {
                if (tree.hasCheckbox(child))
                    checkboxChildren.push(child);
            }, this);

            // If this node has no children with checkbox, its checked state
            // will be returned.
            if (checkboxChildren.length == 0) {
                return node.attributes.checked;
            }

            var allChecked = true;
            Ext.each(checkboxChildren, function(child) {
                if (!updateNodeCheckbox(child)) {
                    allChecked = false;
                    return false;
                }
            }, this);

            tree.setNodeChecked(node, allChecked, false);
            delete unvisitedNodeIds[node.id];

            return allChecked;
        }

        var checkboxNodes = [];

        this.getRootNode().cascade(function(node) {
            if (this.hasCheckbox(node)) {
                checkboxNodes.push(node);
                unvisitedNodeIds[node.id] = true;
            }
        }, this);

        // taking node from the tree order (using shift) should be more efficient
        var node;
        while (node = checkboxNodes.shift()) {
            if (unvisitedNodeIds[node.id])
                updateNodeCheckbox(node);
        }
    },

    /**
     * Method: _handleModelChange
     *
     * This method updates the OpenLayer layers visibility from the state of the
     * checkboxes/radios in the tree.
     *
     * Parameters:
     * clickedNode - {Ext.data.Node} Optional node that was clicked. It can be null
     * checked - {Boolean} checked state of the clicked node, only used if the
     *           clickedNode parameter is not null.
     *
     */
    _handleModelChange: function LT__handleModelChange(clickedNode, checked) {

        // Tree can be modified in two situations:
        //
        // 1) The user clicks on a checkbox
        // 2) The user drags a node to another location
        //
        // Situation 1) could modify the descendants and ancestors of the checkbox clicked
        // Situation 2) could only modify ancestors of the moved node and of the ancestors
        //  of the previous node location.
        //
        // Descendants updating is done below
        //
        // Ancestors updating is done in the _updateCheckboxAncestors() method.

        if (clickedNode) {
            clickedNode.cascade(function(node) {
                this.setNodeChecked(node, checked, false);
            }, this);
        }

        this._updateCheckboxAncestors();

        if (!this.map) {
            return;
        }

        this._updateCachedObjects();

        /**
         * This function reads the visibility of the layers in the map, and returns
         * an {Object} which is mapping between {String} layer names and {Boolean}
         * visibility status of the named layer.
         *
         * Sublayers are included in the list using the
         * <layer name:sublayer name> convention.
         *
         * Returns:
         * {Object} layerVisibility map
         */
        function getVisibilityFromMap() {
            var layerVisibility = {};

            Ext.each(this.map.layers, function(layer) {
                var name = layer.name;
                layerVisibility[name] = layer.visibility;

                if (!(layer instanceof OpenLayers.Layer.WMS) &&
                    !(layer instanceof OpenLayers.Layer.WMS.Untiled) &&
                    !(layer instanceof OpenLayers.Layer.MapServer))
                {
                    return;
                }

                if (!this.layersWithSublayers[layer.name])
                    return;

                // FIXME: base layers and sublayers do not play well for now...
                if (layer.isBaseLayer) {
                    OpenLayers.Console.error("Using sublayers on a base layer " +
                                             "is not supported (base layer is " +
                                             name + ")");
                }

                // Save the original set of sublayers in a property on the
                // layer object. The layer ordering is kept if drag and drop
                // is not used (this is implemented in updateMapFromVisibility()
                // below.
                if (!layer._origLayers) {
                    layer._origLayers = layer.params.LAYERS || layer.params.layers;
                }
                var sublayers = layer._origLayers;

                if (sublayers instanceof Array) {
                    for (var j = 0; j < sublayers.length; j++) {
                        var sublayer = sublayers[j];
                        layerVisibility[name + this.separator + sublayer] = layer.visibility;
                    }
                }
            }, this);
            return layerVisibility;
        }

        /**
         * Walks the tree and updates the given layerVisibility object
         *
         * Parameters:
         * layerVisibility - {Object} Map of layer name to {Boolean}
         *
         * Returns:
         * {Object} updated layerVisibility map
         */
        function updateVisibilityFromTree(layerVisibility) {

            // Clicked node takes precedence for setting state. This map contains
            // as keys the layername that were clicked (so that we do not override
            // them with non clicked nodes).
            var forcedVisibility = {};

            this.getRootNode().cascade(function(node) {
                var checked = node.attributes.checked;
                var layerNames = node.attributes.layerNames;
                var radioGrp = null;

                if (!layerNames)
                    return;

                for (var i = 0; i < layerNames.length; i++) {
                    var layerName = layerNames[i];
                    if (!layerName)
                        continue;

                    if (layerVisibility[layerName] == undefined)
                        OpenLayers.Console.error("Invalid layer: ", layerName);

                    if (node.attributes.radio) {
                        radioGrp = node.attributes.radioGrp || "radioGrp";

                        if (!radioButton[radioGrp])
                            radioButton[radioGrp] = {};

                        radioButton[radioGrp][layerName] = checked;
                    }

                    if (forcedVisibility[layerName])
                        continue;
                    if (node == clickedNode) {
                        if (this.baseLayerNames.indexOf(layerName) != -1) {
                            clickedBaseLayer = layerName;
                        }
                        if (radioGrp) {
                            clickedRadioButton[0]  = radioGrp;
                            clickedRadioButton[1]  = layerName;
                        }
                        forcedVisibility[layerName] = true;
                    }
                    layerVisibility[layerName] = checked;

                }
            }, this);

            return layerVisibility;
        }

        /**
         * Ensure only one baseLayer is visible.
         *
         * Parameters:
         * layerVisibility - {Object} Map of layer name to {Boolean}
         * clickedBaseLayer - {String} name of the base layer that was clicked.
         *                    can be null/undefined
         * currentBaseLayerName - {String} name of the selected base layer
         *
         * Returns:
         * {Object} updated layerVisibility map
         */
        function applyBaseLayerRestriction(layerVisibility, clickedBaseLayer,
                                           currentBaseLayerName) {

            var numBaseLayer = 0;
            for (var i = 0; i < this.baseLayerNames.length; i++) {
                if (layerVisibility[this.baseLayerNames[i]])
                    numBaseLayer++;
            }

            if (numBaseLayer == 1)
                return layerVisibility;

            // Here we have 0 or more that 1 active base layer. We need to
            // change that situation. The strategy is to clear all, and only
            // select one afterwards.

            for (var i = 0; i < this.baseLayerNames.length; i++) {
                layerVisibility[this.baseLayerNames[i]] = false;
            }

            // Higher priority: if a baseLayer was clicked the user intended to
            // select it, so we make sure this is the one active. This will do
            // nothing if the user clicked on an already active base layer.

            if (clickedBaseLayer) {
                layerVisibility[clickedBaseLayer] = true;
                return layerVisibility;
            }

            // Otherwise, restore the initial selected base layer
            if (!currentBaseLayerName)
                return layerVisibility;

            layerVisibility[currentBaseLayerName] = true;
            return layerVisibility;
        }

        /**
         * Ensure only one radio button is checked by group.
         *
         * Parameters:
         * layerVisibility - {Object} Map of layer name to {Boolean}
         * clickedRadiButton - {Array} group name & layer name of the radio button that was clicked.
         * radioButton - {Object} name of all radio button with checked state.
         *               Contain the group name and the layer name.
         * Returns:
         * {Object} updated layerVisibility map
         */
        function applyRadioButtonRestriction(layerVisibility, clickedRadioButton,
                                             radioButton) {
            for (var radioGrp in radioButton) {
                for (var layerName in radioButton[radioGrp]) {
                    if (clickedRadioButton[0] == radioGrp) {
                        layerVisibility[layerName] = layerName == clickedRadioButton[1];
                    } else {
                        layerVisibility[layerName] = radioButton[radioGrp][layerName];
                    }
                }
            }
            return layerVisibility;
        }

        /**
         * Updates the tree from the given layerVisibility object.
         *
         * Parameters:
         * layerVisibility - {Object} Map of layer name to {Boolean}
         */
        function updateTreeFromVisibility(layerVisibility) {

            for (var layerName in layerVisibility) {

                var nodeIds = this.layerToNodeIds[layerName];
                if (!nodeIds)
                    continue;
                for (var i = 0; i < nodeIds.length; i++) {

                    var node = this.nodeIdToNode[nodeIds[i]];
                    if (!node)
                        continue;

                    // only check a node if all the mapped layers are visible
                    var layerNames = node.attributes.layerNames;
                    if (!layerNames) {
                        OpenLayers.Console.error("unexpected state");
                        continue;
                    }

                    var allChecked = true;
                    for (var j = 0; j < layerNames.length; j++) {
                        var layerName = layerNames[j];
                        if (!layerName)
                            continue;
                        if (!layerVisibility[layerName]) {
                            allChecked = false;
                            break;
                        }
                    }
                    this.setNodeChecked(node, allChecked, false);
                }
            }
        }

        /**
         * Updates the map layers from the given visibility variable.
         *
         * Parameters:
         * layerVisibility - {Object} Map of layer name to {Boolean}
         */
        function updateMapFromVisibility(layerVisibility) {

            var wmsLayers = {};

            for (var layerName in layerVisibility) {
                var visible = layerVisibility[layerName];

                var splitName = layerName.split(this.separator);
                if (splitName.length != 2)
                    continue;

                delete layerVisibility[layerName];

                layerName = splitName[0];
                var sublayerName = splitName[1];

                if (!wmsLayers[layerName]) {
                    wmsLayers[layerName] = [];
                }
                if (visible) {
                    wmsLayers[layerName].push(sublayerName);
                }
            }
            // Remove layers with sublayers from layerVisibility, they are handled
            // separately.
            for (layerName in wmsLayers) {
                if (layerVisibility[layerName] !== undefined)
                    delete layerVisibility[layerName];
            }

            for (var layerName in layerVisibility) {
                var layer = this.layerNameToLayer[layerName];
                if (!layer) {
                    OpenLayers.Console.error("Non existing layer name", layerName);
                    continue;
                }

                if (this.baseLayerNames.indexOf(layerName) != -1) {
                    if (layerVisibility[layerName]) {
                        this.map.setBaseLayer(layer);
                    }
                } else {
                    layer.setVisibility(layerVisibility[layerName]);
                }
            }

            for (var layerName in wmsLayers) {
                var layer = this.layerNameToLayer[layerName];
                var sublayers = wmsLayers[layerName];

                if (layer.isBaseLayer) {
                    OpenLayers.Console.error("base layer for sublayer " +
                                             "are not supported");
                    return;
                }
                if (sublayers.length == 0) {
                    layer.setVisibility(false, true);
                } else {
                    // If drag and drop is not active, we try to preserve the
                    //  sublayer order from the one set during layer construction.
                    //  We stick a property on the layer object to remember the
                    //  the original ordering.
                    if (!this.enableDD) {

                        if (!layer._origLayers) {
                            OpenLayers.Console.error("Assertion failure");
                        }
                        var origLayers = layer._origLayers;
                        var orderedLayers = [];

                        for (var i = 0; i < origLayers.length; i++) {
                            var l = origLayers[i];
                            if (sublayers.indexOf(l) != -1)
                                orderedLayers.push(l);
                        }
                        sublayers = orderedLayers;
                    }

                    // layer has to be redrawn only if its sublayers
                    // have changed
                    var layerParamName = layer.params.LAYERS ? "LAYERS" : "layers";
                    if (!mapfish.Util.arrayEqual(layer.params[layerParamName], sublayers)) {
                        layer.params[layerParamName] = sublayers;
                        layer.redraw();
                    }

                    layer.setVisibility(true, true);
                }
            }
        }

        var currentBaseLayerName;

        if (this.map.baseLayer)
            currentBaseLayerName = this.map.baseLayer.name;
        var clickedBaseLayer;
        var radioButton = {};
        var clickedRadioButton = [];

        // Definition:
        // A sublayer is a selectable layer inside a layer.

        var layerVisibility = getVisibilityFromMap.call(this);

        layerVisibility = updateVisibilityFromTree.call(this, layerVisibility);

        applyBaseLayerRestriction.call(this, layerVisibility, clickedBaseLayer,
                                       currentBaseLayerName);

        applyRadioButtonRestriction.call(this, layerVisibility, clickedRadioButton,
                                         radioButton);

        updateTreeFromVisibility.call(this, layerVisibility);

        updateMapFromVisibility.call(this, layerVisibility);
    },

    /**
     * Method: _extractOLModel
     *
     * Builds a model object from the list of available layers in the map. For
     * layers that can contain sublayers (WMS, Mapserver), children are created
     * for each sublayer.
     * The <displayInLayerSwitcher> property of the layer can be used not to
     * show that layer in the tree if it is false.
     * The LayerTree <ascending> property controls the ordering of the layer in
     * the tree.
     *
     * Returns:
     * {Array(Object)} A model object extracted from the list of layers.
     */
    _extractOLModel: function LT__extractOLModel() {
        // TODO: how to deal with baseLayers?
        var layers = [];

        var layersArray = this.map.layers.slice();

        if (!this.ascending) {
            layersArray.reverse();
        }
        for (var i = 0; i < layersArray.length; i++) {
            var l = layersArray[i];
            var wmsChildren = [];

            if (l instanceof OpenLayers.Layer.WMS ||
                l instanceof OpenLayers.Layer.WMS.Untiled ||
                l instanceof OpenLayers.Layer.MapServer) {

                var sublayers = l.params.LAYERS || l.params.layers;

                if (sublayers instanceof Array) {
                    for (var j = 0; j < sublayers.length; j++) {
                        var w = sublayers[j];

                        var iconUrl;
                        if (this.showWmsLegend) {
                            iconUrl = mapfish.Util.getIconUrl(l.url, {layer: w});
                        }

                        var wmsChild = {text: w, // TODO: i18n
                            checked: l.getVisibility(),
                            icon: iconUrl,
                            layerName: l.name + this.separator + w,
                            children: [],
                            cls: "cf-wms-node"
                        };
                        if(this.ascending) {
                            wmsChildren.push(wmsChild);
                        } else {
                            wmsChildren.unshift(wmsChild);
                        }
                    }
                }
            }

            var info = {
                text: l.name, // TODO: i18n
                checked: l.getVisibility(),
                layerName: (wmsChildren.length > 0 ? null : l.name),
                children: wmsChildren
            };
            if (!l.displayInLayerSwitcher) {
                // We hide the layers using a fake uiProvider instead of
                // removing them from the model, so that their position
                // is remembered when drag and drop is used.
                info.uiProvider = function() {};
                info.hidden = true;
                info.uiProvider.prototype = {
                    render: function() {},
                    renderIndent: function() {},
                    updateExpandIcon: function() {}
                };
            }
            layers.push(info);
        }

        return layers;
    },

    /**
     * Method: _updateOrder
     *
     * Updates the stacking order of the OpenLayer layers from the order set
     * in the layer tree.
     */
    _updateOrder: function() {

        this._updateCachedObjects();

        // TODO: handle sublayers correctly
        //var subLayers = {};

        // DESIGN CHOICE:
        // Layers available on map but not on model will be put in the
        // bottom (beginning of map.layers array)

        function layerIndex(layers, name) {
            for (var i = 0; i < layers.length; i++) {
                var l = layers[i];
                if (l.name == name)
                    return i;
            }
            return -1;
        }

        var orderedLayers = this.map.layers.slice();
        var seenLayers = {};

        var nodes = [];
        this.getRootNode().cascade(function(node) {
            if (this.ascending)
                nodes.push(node);
            else
                nodes.unshift(node);
        }, this);

        Ext.each(nodes, function(node) {
            var layers = this.nodeIdToLayers[node.id];
            if (!layers)
                return;
            Ext.each(layers, function(layer) {
                var layerName = layer.name;
                if (seenLayers[layerName])
                    return;
                seenLayers[layerName] = true;

                var index = layerIndex(orderedLayers, layerName);
                if (index == -1 || !this.layerNameToLayer[layerName]) {
                    throw new Error("Layer " + layerName + " not available");
                }

                orderedLayers.splice(index, 1);
                orderedLayers.push(this.layerNameToLayer[layerName]);

            }, this);
        }, this);

        this._updateCheckboxAncestors();

        this.map.layers = orderedLayers;

        for (var i = 0; i < this.map.layers.length; i++) {
            this.map.setLayerZIndex(this.map.layers[i], i);
        }
    },

    /**
     * Method: _fixupModel
     *
     * Canonicalize the model (for instance, convert layerName to layerNames
     * properties).
     */
    _fixupModel: function() {

        // The layerNames property has to be filled before calling
        // _updateCachedObjects()
        this.getRootNode().cascade(function(node) {
            var attrs = node.attributes;
            if (!attrs.layerNames && attrs.layerName) {
                attrs.layerNames = [attrs.layerName];
                delete attrs.layerName;
            }
        }, this);

        if (this.map)
            this._updateCachedObjects();

        this.getRootNode().cascade(function(node) {
            var layers;
            if (!node.attributes.radio && (!this.map || !(layers = this.nodeIdToLayers[node.id])))
                return;


            var isBaseLayer = false;
            var displayInLayerSwitcher = false;
            if (layers) {
                isBaseLayer = true;
                Ext.each(layers, function(layer) {
                    if (!layer.isBaseLayer) {
                        isBaseLayer = false;
                    }
                    if (layer.displayInLayerSwitcher) {
                       displayInLayerSwitcher = true;
                    }
                }, this);
            } else {
                displayInLayerSwitcher = true;                
            }

            if ((isBaseLayer || node.attributes.radio) && displayInLayerSwitcher) {
                node.attributes.uiProvider = mapfish.widgets.RadioTreeNodeUI;
                // The ui may already habe been instanciated here, so we
                // replace it in this case.
                if (node.ui)
                    node.ui = new mapfish.widgets.RadioTreeNodeUI(node);
            }
        }, this);
    },

    /**
     * Method: initComponent
     *
     * Overrides super-class initComponent method. If no model is available, it
     * builds a default flat model from the map layers. Then it builds the Ext
     * tree structure from that model. After this method is called, the <model>
     * property shouldn't be used anymore, because it is not kept in sync with
     * the node changes. Instead, use the {Ext.data.Tree} or {Ext.data.Node}
     * methods on the tree <root> property.
     */
    initComponent: function() {

        this.eventModel = new mapfish.widgets.LayerTreeEventModel(this);

        mapfish.widgets.LayerTree.superclass.initComponent.call(this);

        this.addListener("checkchange", function checkChange(node, checked) {
            this._handleModelChange(node, checked);
        }, this);
        this.addListener("radiochange", function radioChange(node, checked) {
            this._handleModelChange(node, checked);
        }, this);

        this._automaticModel = !this.model;

        if (!this.model) {
            this.model = this._extractOLModel();
        }

        var root = {
            text: 'Root',
            draggable: false, // disable root node dragging
            id: 'source',
            children: this.model,
            leaf: false
        };

        // Pre-build the tree so that non-expanded nodes exist in the model.

        function buildTree(attributes) {
            var node = new Ext.tree.TreeNode(attributes);

            var cs = attributes.children;
            node.leaf = !cs;
            if (!cs)
                return node;

            for (var i = 0; i < cs.length; i++) {
                // XXX This index is sometimes undefined on IE for unknown reason
                if (!cs[i]) {
                    continue;
                }

                node.appendChild(buildTree(cs[i]));
            }
            return node;
        }

        var rootNode = buildTree(root);
        this.setRootNode(rootNode);

        this._fixupModel();

        if (this.enableDD) {
            this.addListener("dragdrop", function() {
                this._updateOrder(arguments);
            }, this);
            this.addListener('nodedragover', this.isDragAllowed, this);
        }

        // Synchronize the OL layer state if a usermodel is supplied
        // This means that the layers checked state defined in the model takes
        // precedence over the OL layer state

        // FIXME: is this still needed in any case if we want the state of a
        //  layer / sublayers to be updated?
        if (!this._automaticModel) {
            this._handleModelChange(null, null);
            if (this.enableDD) {
                this._updateOrder();
            }
        }
    },

    /**
     * Method: isDragAllowed
     * Check wether a drag and drop is possible.
     * 
     * Parameters:
     * e - The drag and drop event
     */
    isDragAllowed: function(e) {
        var draggedNode = e.data.node;
        var targetParentNode = e.target;
        if (e.point == "above" || e.point == "below") {
            targetParentNode = targetParentNode.parentNode;
        }
        if (draggedNode.parentNode != targetParentNode) {
            //cannot change parent. For example, cannot move a WMS layer from one
            //OL layer to another or cannot move an OL layer inside another OL layer.
            return false;
        }
        return true;
    },

    /**
     * Method: onRender
     * Called by Ext when the component is rendered.
     */
    onRender: function(container, position) {
        if (!this.el) {
            this.el = document.createElement('div');
        }

        mapfish.widgets.LayerTree.superclass.onRender.apply(this, arguments);
    }

});
Ext.reg('layertree', mapfish.widgets.LayerTree);

