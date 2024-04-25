/**
 * @license
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @fileoverview The full custom JSON generator built during the custom
 * generator codelab.
 */

import * as Blockly from 'blockly';

export const jsonGenerator = new Blockly.Generator('JSON');

const Order = {
    ATOMIC: 0,
};


jsonGenerator.scrub_ = function (block, code, thisOnly) {
    const nextBlock = block.nextConnection && block.nextConnection.targetBlock();
    if (nextBlock && !thisOnly) {
        return code + ',\n' + jsonGenerator.blockToCode(nextBlock);
    }
    return code;
};


jsonGenerator.forBlock['repeat'] = function (block, generator) {
    const statementMembers = generator.statementToCode(block, 'MEMBERS');
    const count = block.getFieldValue('COUNT');
    const jsonString = `{"request_id": "repeat", "operation": ${1}, "repeat" : ${count}, "repeat_objects": [${statementMembers}]}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }

    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['induction_control'] = function (block, generator) {
    const temperature = block.getFieldValue('TEMPERATURE');
    const induction_power = block.getFieldValue('POWER');
    const jsonString = `{"request_id": "induction_control","operation": ${2},"target_temperature" : ${temperature}, "induction_power": ${induction_power}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['timeout'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const jsonString = `{"request_id": "timeout", "operation": ${3}, "duration" : ${duration}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['dispense'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const tilt_angle = block.getFieldValue('TILT_ANGLE');
    const jsonString = `{"request_id": "dispense", "operation": ${4}, "tilt_angle": ${tilt_angle}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['flip'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const tilt_angle = block.getFieldValue('TILT_ANGLE');
    const jsonString = `{"request_id": "flip", "operation": ${5}, "duration" : ${duration}, "tilt_angle": ${tilt_angle}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['stir'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const jsonString = `{"request_id": "stir", "operation": ${6}, "duration" : ${duration}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['tilt'] = function (block, generator) {
    const angle = block.getFieldValue('TILT_ANGLE');
    const jsonString = `{"request_id": "tilt", "operation": ${7}, "tilt_angle" : ${angle}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['ab_tilt'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const duration = 0;
    const jsonString = `{"request_id": "A-B Tilt", "operation": ${8}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['abc_tilt'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const angleC = block.getFieldValue('ANGLE_C');
    const duration = 0;
    const jsonString = `{"request_id": "A-B-C Tilt", "operation": ${9}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}, "angle_c": ${angleC}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['abcd_tilt'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const angleC = block.getFieldValue('ANGLE_C');
    const angleD = block.getFieldValue('ANGLE_D');
    const duration = 0;
    const jsonString = `{"request_id": "A-B-C-D Tilt", "operation": ${10}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}, "angle_c": ${angleC}, "angle_d": ${angleD}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['infinite_rotate'] = function (block, generator) {
    const duration = 0;
    const jsonString = `{"request_id": "Infinite Rotate", "operation": ${11}, "enable" : ${true}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['disable_infinite_rotate'] = function (block, generator) {
    const duration = 0;
    const jsonString = `{"request_id": "Infinite Rotate", "operation": ${11}, "enable" : ${false}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['rotate'] = function (block, generator) {
    const angle = block.getFieldValue('ANGLE');
    const jsonString = `{"request_id": "Rotate", "operation": ${12}, "angle" : ${angle}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};


jsonGenerator.forBlock['ab_rotate'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const duration = 0;
    const jsonString = `{"request_id": "A-B Rotate", "operation": ${13}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['abc_rotate'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const angleC = block.getFieldValue('ANGLE_C');
    const duration = 0;
    const jsonString = `{"request_id": "A-B-C Rotate", "operation": ${14}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}, "angle_c": ${angleC}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['abcd_rotate'] = function (block, generator) {
    const angleA = block.getFieldValue('ANGLE_A');
    const angleB = block.getFieldValue('ANGLE_B');
    const angleC = block.getFieldValue('ANGLE_C');
    const angleD = block.getFieldValue('ANGLE_D');
    const duration = 0;
    const jsonString = `{"request_id": "A-B-C-D Rotate", "operation": ${15}, "duration" : ${duration}, "angle_a": ${angleA}, "angle_b": ${angleB}, "angle_c": ${angleC}, "angle_d": ${angleD}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['pump_oil'] = function (block, generator) {
    const volume = block.getFieldValue('VOLUME');
    const jsonString = `{"request_id": "Pump Oil", "operation": ${16}, "volume" : ${volume}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['pump_water'] = function (block, generator) {
    const volume = block.getFieldValue('VOLUME');
    const jsonString = `{"request_id": "Pump Water", "operation": ${17}, "volume" : ${volume}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};


jsonGenerator.forBlock['user_action'] = function (block, generator) {
    const title = block.getFieldValue('TITLE');
    const message = block.getFieldValue('MESSAGE');
    const jsonString = `{"request_id": "User Action", "operation": ${18}, "title" : "${title}", "message": "${message}"}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};


jsonGenerator.forBlock['wash'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const jsonString = `{"request_id": "Wash", "operation": ${19}, "duration" : ${duration}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['commit_ingredient'] = function (block, generator) {
    const duration = block.getFieldValue('DURATION');
    const jsonString = `{"request_id": "Commit Ingredient", "operation": ${20}, "duration" : ${duration}}`;
    let encoded = JSON.parse(jsonString);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};

jsonGenerator.forBlock['request_ingredient'] = function (block, generator) {
    const ingredient = block.getFieldValue('INGREDIENT');
    const quantity = block.getFieldValue('QUANTITY');
    const jsonString = `{"request_id": "Request Ingredient", "operation": ${21}, "quantity": ${quantity}}`;
    let encoded = JSON.parse(jsonString);
    encoded.ingredient = JSON.parse(ingredient);
    encoded.icon_data = {
        code_point: 0xf666,
        font_family: "MaterialIcons"
    }
    return JSON.stringify(encoded);
};


jsonGenerator.forBlock['lists_create_with'] = function (block, generator) {
    const values = [];
    for (let i = 0; i < block.itemCount_; i++) {
        const valueCode = generator.valueToCode(block, 'ADD' + i, Order.ATOMIC);
        if (valueCode) {
            values.push(valueCode);
        }
    }
    const valueString = values.join(',\n');
    const indentedValueString = generator.prefixLines(
        valueString,
        generator.INDENT,
    );
    const codeString = '[\n' + indentedValueString + '\n]';
    return [codeString, Order.ATOMIC];
};

