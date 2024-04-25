/**
 * @license
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

export const toolbox = {
    kind: 'categoryToolbox',
    contents: [
        {
            kind: "category",
            name: "Utility",
            contents: [
                {
                    kind: 'block',
                    type: 'repeat'
                },
                {
                    kind: 'block',
                    type: 'user_action'
                },
                {
                    kind: 'block',
                    type: 'timeout'
                }
            ]
        },
        {
            kind: "category",
            name: "Devices",
            contents: [
                {
                    kind: 'block',
                    type: 'induction_control'
                },
                {
                    kind: 'block',
                    type: 'pump_oil'
                },
                {
                    kind: 'block',
                    type: 'pump_water'
                },
            ]
        },
        {
            kind: "category",
            name: "Wok Tilt Motor",
            contents: [
                {
                    kind: 'block',
                    type: 'tilt'
                },
                {
                    kind: 'block',
                    type: 'ab_tilt'
                },
                {
                    kind: 'block',
                    type: 'abc_tilt'
                },
                {
                    kind: 'block',
                    type: 'abcd_tilt'
                },
            ]
        },
        {
            kind: "category",
            name: "Wok Rotate Motor",
            contents: [
                {
                    kind: 'block',
                    type: 'infinite_rotate'
                },
                {
                    kind: 'block',
                    type: 'disable_infinite_rotate'
                },
                {
                    kind: 'block',
                    type: 'rotate'
                },

                {
                    kind: 'block',
                    type: 'ab_rotate'
                },
                {
                    kind: 'block',
                    type: 'abc_rotate'
                },
                {
                    kind: 'block',
                    type: 'abcd_rotate'
                },
            ]
        },
        {
            kind: "category",
            name: "Ingredient",
            contents: [
                {
                    kind: 'block',
                    type: 'request_ingredient'
                },
                {
                    kind: 'block',
                    type: 'commit_ingredient'
                },
            ]
        },
        {
            kind: "category",
            name: "Finisher",
            contents: [
                {
                    kind: 'block',
                    type: 'wash'
                },

                {
                    kind: 'block',
                    type: 'dispense'
                },
            ]
        },
        {
            kind: "category",
            name: "Template",
            contents: [
                {
                    kind: 'block',
                    type: 'flip'
                },
                {
                    kind: 'block',
                    type: 'stir'
                },
            ]
        },


    ],
};
