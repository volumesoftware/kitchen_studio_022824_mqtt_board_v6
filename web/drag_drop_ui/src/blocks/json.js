/**
 * @license
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @fileoverview All the custom JSON-related blocks defined in the custom
 * generator codelab.
 */

import * as Blockly from 'blockly';
import {FieldSlider} from '@blockly/field-slider';


export const blocks = Blockly.common.createBlockDefinitionsFromJsonArray([]);

let inductionPowerLevel = [
    ["OFF", "0"], // The first element is the display text, the second is the value
    ["600W", "1"], // The first element is the display text, the second is the value
    ["1200W", "2"],
    ["1800W", "3"],
    ["2500W", "4"],
    ["3200W", "5"],
    ["3800W", "6"],
    ["4500W", "7"],
    ["5000W", "8"],
];


Blockly.Blocks['repeat'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Repeat").appendField("count")
            .appendField(new Blockly.FieldNumber(1), "COUNT");

        // Create a statement input which allows other blocks to be stacked below.
        this.appendStatementInput("MEMBERS")
            .setCheck(null); // Setting to null allows any blocks to be connected.

        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(200);
        this.setTooltip("");
        this.setHelpUrl("");
        // Additional functionality can be added as needed
    }
};

Blockly.Blocks['induction_control'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Induction Control")
            .appendField("temperature (°C)").appendField(new FieldSlider(50, 30, 300), "TEMPERATURE")
            .appendField("induction power").appendField(new Blockly.FieldDropdown(() => {
            return inductionPowerLevel;
        }), "POWER")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(200);
        this.setTooltip("");
        this.setHelpUrl("");
        // Additional functionality can be added as needed
    }
};


// Function to update the dropdown options for all 'cook_with_timeout' blocks
Blockly.Blocks['heat_to_temperature'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Heat to temperature")
            .appendField("tilt angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "TILT_ANGLE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(200);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

// Function to update the dropdown options for all 'cook_with_timeout' blocks
Blockly.Blocks['time_out_heat'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Timeout Heat")
            .appendField("duration (s)").appendField(new Blockly.FieldNumber(15), "DURATION")
            .appendField("tilt_angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "TILT_ANGLE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(200);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['timeout'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Timeout")
            .appendField("duration (s)").appendField(new Blockly.FieldNumber(15), "DURATION")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(200);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
}

// Function to update the dropdown options for all 'cook_with_timeout' blocks
Blockly.Blocks['dispense'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Dispense")
            .appendField("tilt_angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "TILT_ANGLE")
        this.setPreviousStatement(true, null);
        // this.setNextStatement(true, null);
        this.setColour(891);
        this.setTooltip("");
        this.setHelpUrl("");
        this.setNextStatement(true, null);
        // Assume updateRecipeDropdown is a globally available function
    }
};

//@todo
Blockly.Blocks['flip'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Flip")
            .appendField("duration (s)").appendField(new Blockly.FieldNumber(15), "DURATION")
            .appendField("tilt_angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "TILT_ANGLE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(310);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};
Blockly.Blocks['stir'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Stir")
            .appendField("duration (s)").appendField(new Blockly.FieldNumber(15), "DURATION")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(720);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['tilt'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Tilt")
            .appendField("angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "TILT_ANGLE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['ab_tilt'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("AB Tilt")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['abc_tilt'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("ABC Tilt")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
            .appendField("angle C").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_C")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['abcd_tilt'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("ABCD Tilt")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
            .appendField("angle C").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_C")
            .appendField("angle D").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_D")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['infinite_rotate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Infinite Rotate")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['disable_infinite_rotate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Disable Infinite Rotate")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};


Blockly.Blocks['rotate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Rotate")
            .appendField("angle").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['ab_rotate'] = {
    init: function () {

        this.appendDummyInput()
            .appendField("AB Rotate")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['abc_rotate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("ABC Rotate")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
            .appendField("angle C").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_C")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['abcd_rotate'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("ABCD Rotate")
            .appendField("angle A").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_A")
            .appendField("angle B").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_B")
            .appendField("angle C").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_C")
            .appendField("angle D").appendField(new Blockly.FieldAngle(0, null, {
            offset: 90,
            wrap: (-179.9, 180)
        }), "ANGLE_D")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(928);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['pump_oil'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Pump Oil")
            .appendField("volume (ml)").appendField(new Blockly.FieldNumber(15), "VOLUME")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['pump_water'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Pump Water")
            .appendField("volume (ml)").appendField(new Blockly.FieldNumber(15), "VOLUME")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(120);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['user_action'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("User Action")
            .appendField("title").appendField(new Blockly.FieldTextInput(), "TITLE")
            .appendField("message").appendField(new Blockly.FieldMultilineInput(), "MESSAGE")
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(600);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};


// Function to update the dropdown options for all 'cook_with_timeout' blocks
Blockly.Blocks['wash'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Wash wok")
            .appendField("duration").appendField(new Blockly.FieldNumber(200), "DURATION")
        // this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(100);
        this.setTooltip("");
        this.setHelpUrl("");
        this.setPreviousStatement(true, "canWash");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['commit_ingredient'] = {
    init: function () {
        this.appendDummyInput()
            .appendField("Commit Ingredient");
        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(629);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
    }
};

Blockly.Blocks['request_ingredient'] = {
    init: async function () {
        let menuGenerator = JSON.parse(localStorage.getItem('ingredientMenuGenerator'));
        if (menuGenerator == null) {
            menuGenerator = [["Loading ingredients...", "LOADING"]];
        }


        this.appendDummyInput()
            .appendField("Request Ingredient");
        this.appendDummyInput()
            .appendField("ingredient")
            .appendField(new Blockly.FieldDropdown(menuGenerator), "INGREDIENT")
            .appendField("quantity (gram)").appendField(new Blockly.FieldNumber(), "QUANTITY");

        this.setPreviousStatement(true, null);
        this.setNextStatement(true, null);
        this.setColour(629);
        this.setTooltip("");
        this.setHelpUrl("");
        // Assume updateRecipeDropdown is a globally available function
        await updateRecipeDropdown(this); // Update the dynamic dropdown
    }
};

async function updateRecipeDropdown(block) {
    var dropdownField = block.getField("INGREDIENT");
    let response = await fetch('http://localhost/api/ingredient/ingredients/');
    if (response.ok) { // if HTTP-status is 200-299
        let ingredients = await response.json();
        // Assuming you want to map the API response to the dropdown options correctly
        if (ingredients.length > 0) {
            let menuGenerator = ingredients.map(item => [`(${item.id}) ${item.ingredient_name}`, JSON.stringify(item)]);
            dropdownField.menuGenerator_ = menuGenerator;
            dropdownField.forceRerender();
            localStorage.setItem('ingredientMenuGenerator', JSON.stringify(menuGenerator));
        } else {
        }
    } else {
        alert("HTTP-Error: " + response.status);
    }


}
