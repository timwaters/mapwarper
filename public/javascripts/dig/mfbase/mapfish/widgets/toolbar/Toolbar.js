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

Ext.namespace('mapfish.widgets.toolbar');

/**
 * Class: mapfish.widgets.toolbar.Toolbar
 * A toolbar shows a set of OpenLayers Controls and handle activating them.
 *
 * Simple example usage:
 * (start code)
 * var toolbar = new mapfish.widgets.toolbar.Toolbar({map: map});
 * toolbar.render('buttonbar');
 * toolbar.addControl(
 *     new OpenLayers.Control.ZoomBox({title: 'Zoom in'}), 
 *     {iconCls: 'zoomin', toggleGroup: 'navigation'});
 * toolbar.addControl(
 *     new OpenLayers.Control.DragPan({title: 'Drag or pan', isDefault: true}), 
 *     {iconCls: 'pan', toggleGroup: 'navigation'});
 * toolbar.activate();
 * (end)
 *
 * Some attributes from the control are used by the toolbar:
 *  - isDefault: true for the default button of the given group.
 *  - title: will be used for the tooltip.
 *
 * On the Ext button side (second parameter of addControl), some options are of
 * interest:
 *  - toggleGroup: Name of the toggle group the button is member of.
 *  - iconCls: The CSS class for displaying the button.
 *
 * Inherits from:
 * - {Ext.Toolbar}
 */

/**
 * Constructor: mapfish.widgets.toolbar.Toolbar
 * Create a new Toolbar
 *
 * Parameters:
 * config - {Object} Config object
 */

mapfish.widgets.toolbar.Toolbar = function(config) {
    Ext.apply(this, config);
    mapfish.widgets.toolbar.Toolbar.superclass.constructor.call(this);
};

Ext.extend(mapfish.widgets.toolbar.Toolbar, Ext.Toolbar, {

    /**
     * Property: controls
     * Array({<OpenLayers.Control>})
     */
    controls: null,

    /**
     * Property: state
     * Object
     */
    state: null,

    /**
     * Property: configurable
     * Boolean
     */
    configurable: false,
    
    /** 
     * Property: _buttons 
     * Array({<Ext.Toolbar.Button>}) 
     * "buttons" is not available (already used in Ext.Toolbar)
     */ 
    _buttons: null,

    // private
    initComponent: function() {
        mapfish.widgets.toolbar.Toolbar.superclass.initComponent.call(this);
        this.controls = [];
        this._buttons = [];
        this.autoWidth = true;
        this.autoHeight = true;
        Ext.QuickTips.init();
    },

    /**
     * Method: addControl
     * Add a control to the toolbar, the control will be represented by a button
     *
     * Parameters:
     * control - {<OpenLayers.Control>}
     * options - the config object for the newly created Ext.Toolbar.Button
     *
     * Returns:
     * {<Ext.Toolbar.Button>} The added button instance
     */
    addControl: function (control, options) {
        control.visible = true;
        this.controls.push(control);
        if (!control.map) {
            this.map.addControl(control);
        }
        var button = new Ext.Toolbar.Button(options);
        if (!button.tooltip) {
            button.tooltip = control.title;
        }
        button.enableToggle = (control.type != OpenLayers.Control.TYPE_BUTTON);
        if (control.isDefault) {
            button.pressed = true;
        }
        if (control.type == OpenLayers.Control.TYPE_BUTTON) {
            button.on("click", control.trigger, control);
        } else {
            button.on("toggle", function(button, pressed) {
                this.toggleHandler(control, pressed);
            }, this);
            // make sure the state of the control and the state of the
            // button match
            control.events.on({
                "activate": this.onControlActivate,
                "deactivate": this.onControlDeactivate,
                scope: this
            });
        }
        this.add(button);
        this._buttons.push(button);
        return button;
    },

    /**
     * Method: removeControl
     * Remove a control from the toolbar.
     *
     * Parameters:
     * control - {<OpenLayers.Control>} The control to remove from
     *     the toolbar.
     */
    removeControl: function (control) {
        var button = this.getButtonForControl(control);

        button.destroy();
        OpenLayers.Util.removeItem(this._buttons, button);

        control.events.un({
            "activate": this.onControlActivate,
            "deactivate": this.onControlDeactivate,
            scope: this
        });
        this.map.removeControl(control);
        OpenLayers.Util.removeItem(this.controls, control);
    },

    /**
     * onControlActivate
     * Called when a control is activated.
     *
     * Parameters:
     * evt - {Object} An object with an object property referencing
     *     the control.
     */
    onControlActivate: function(evt) {
        var control = evt.object;
        var button = this.getButtonForControl(control);
        button.toggle(true);
    },

    /**
     * onControlDeactivate
     * Called when a control is deactivated.
     *
     * Parameters:
     * evt - {Object} An object with an object property referencing
     *     the control.
     */
    onControlDeactivate: function(evt) {
        var control = evt.object;
        var button = this.getButtonForControl(control);
        button.toggle(false);
        this.checkDefaultControl(button);
    },

    /**
     * Method: getControlByClassName
     * Pass in the CLASS_NAME of a control as a string and return the control itself
     *
     * Parameters: 
     * className - string
     *
     * Returns:
     * {<OpenLayers.Control>} The requested control.
     */
    getControlByClassName: function(className) {
        if (this.controls) {
            for (var i = 0;  i < this.controls.length; i++) {
                if (this.controls[i].CLASS_NAME == className) {
                    return this.controls[i];
                }
            }
        }
        return null;
    },

    /**
     * Method: getButtonForControl
     * Pass in a control and return the button attached to this control
     *
     * Parameters:
     * control - {<OpenLayers.Control>} A control which was previously added to the toolbar
     *
     * Returns:
     * {<Ext.Toolbar.Button>} The requested button.
     */
    getButtonForControl: function(control) { 
        if (this.controls) { 
            for (var i = 0;  i < this.controls.length; i++) { 
                if (this.controls[i] == control) { 
                    return this._buttons[i];
                } 
            } 
        } 
        return null;
    },

    /**
     * Method: activate
     * Activates the toolbar, either by restoring a given state (if configurable) or the default one.
     */
    activate: function() {
        if (this.configurable) {
            this.applyState(this.state);
            var mb = new Ext.Toolbar.Button({'text': '+'});
            mb.menu = new Ext.menu.Menu();
            for(var i = 0; i < this.controls.length; i++) {
                mb.menu.add({
                    'style': 'height:25px',
                    'text': '<div style="position: relative; left: 25px; top: -15px;" class="' + this._buttons[i].iconCls + '"/>',
                    checked: this.controls[i].visible,
                    scope: {
                        toolbar: this, 
                        button: this._buttons[i], 
                        control: this.controls[i]
                    },
                    checkHandler: function(item, checked) {
                        if (checked) {
                            this.control.visible = true;
                            if (this.control.isDefault) {
                                this.control.activate();
                            } 
                            this.button.show();
                        } else {
                            this.control.visible = false;
                            this.control.deactivate();
                            this.button.hide();
                        }
                        this.toolbar.saveState();
                    }
                });
            }
            this.add(mb);
        } else {
            for (var j = 0, c; j < this.controls.length; j++) {
                c = this.controls[j];
                if(c.isDefault) {
                    c.activate();
                }
            }
        }
    },

    /**
     * Method: deactivate
     * Deactivates all controls in this toolbar.
     */
    deactivate: function() {
        for(var i = 0; i < this.controls.length; i++) {
            this.controls[i].deactivate();
        }
    },

    /**
     * Method: applyState
     * Apply the state to the toolbar upon loading
     *
     * Parameters:
     * state - {<Object>}
     */
    applyState: function(state){
        if (!state) {
            return false;
        }
        this.state = state;
        var cs = state.controls;
        if (cs) {
            for(var i = 0, len = cs.length; i < len; i++) {
                var s = cs[i];
                var c = this.getControlByClassName(s.id);
                if (c) {
                    c.visible = s.visible;
                    if (!c.visible) {
                        this._buttons[i].hide();
                    }
                }
            }
        }
    },

    /**
     * Method: getState
     * Function that builds op the state of the toolbar and returns it
     */
    getState: function() {
        var o = {controls: []};
        for (var i = 0, c; i < this.controls.length; i++) {
            c = this.controls[i];
            o.controls[i] = {
                id: c.CLASS_NAME,
                visible: c.visible
            };
        }
        return o;
    },

    /**
     * Method: toggleHandler
     * Called when a button is toggled.
     *
     * Parameters:
     * button - {<Ext.Toolbar.Button>}
     * control - {<OpenLayers.Control>}
     */
    toggleHandler: function(control, pressed) {
        if(pressed != control.active) {
            if (pressed) {
                control.activate();
            } else {
                control.deactivate();
            }
        }
    },

    /**
     * Method: checkDefaultControl
     * Check if there is a control active in the button's group. If not,
     * activate the default one (if any).
     *
     * Parameters:
     * button - {<Ext.Toolbar.Button>}
     */
    checkDefaultControl: function(button) {
        var group = button.toggleGroup;
        if(group) {
            var defaultControl = null;
            for (var j = 0; j < this.controls.length; j++) {
                var curButton = this._buttons[j];
                if(curButton.toggleGroup == group) {
                    var control = this.controls[j];
                    if(control.active) {
                        //found one button active in the group => OK
                        return;
                    } else if(control.isDefault) {
                        defaultControl = control;
                    }
                }
            }

            if(defaultControl) {
                //no active control found, activate the group's default one
                defaultControl.activate();
            }
        }        
    }
});
Ext.reg('toolbar', mapfish.widgets.toolbar.Toolbar);
