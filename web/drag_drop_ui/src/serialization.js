/**
 * @license
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

import * as Blockly from 'blockly/core';
import Swal from "sweetalert2";

// Use a unique storage key for this codelab
const storageKey = 'jsonGeneratorWorkspace';

/**
 * Saves the state of the workspace to browser's local storage.
 * @param {Blockly.Workspace} workspace Blockly workspace to save.
 * @param backpack
 */
export const save = async function (workspace, backpack) {
    console.log('saving')
    const backpackContents = backpack.getContents();
    if (backpackContents.length > 0) {

        await fetch("http://localhost/api/system-settings/backpack/", {
            headers: {"Content-Type": "application/json; charset=utf-8"},
            method: 'post',
            body: JSON.stringify(backpackContents)
        });
    }
    const data = Blockly.serialization.workspaces.save(workspace);
    window.localStorage?.setItem(storageKey, JSON.stringify(data));

};

/**
 * Loads saved state from local storage into the given workspace.
 * @param {Blockly.Workspace} workspace Blockly workspace to load into.
 * @param backpack
 */
export const load = async function (workspace, backpack) {


    const currentUrl = window.location.href;
    const myURLObj = new URL(currentUrl);
    var recipeId = myURLObj.searchParams.get('recipeId')

    try {
        const response = await fetch(`http://localhost/api/recipe/recipe/${recipeId}/`);

        if (!response.ok) {
            // If response is not ok, throw an error
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        const d = await response.json();
        var data = d.work_space_data;
        console.log(d)
        if (!data) {
            data = window.localStorage?.getItem(storageKey);
            if (!data) return;
        }

        try {
            Blockly.Events.disable();
            const parsedData = JSON.parse(data);
            Blockly.serialization.workspaces.load(parsedData, workspace, false);
            Blockly.Events.enable();
        } catch (e) {
            console.log(e)
        }

        // Further processing of data if needed
    } catch (error) {
        console.error('Error occurred:', error.message);
    }

    const res = await fetch(`http://localhost/api/system-settings/backpack/`);
    if (!res.ok) {
        throw new Error(`HTTP error! Status: ${res.status}`);
    }
    const backPackCache = await res.json();
    if (backPackCache !== null && backPackCache !== '') {
        try {
            const savedBackpackData = JSON.parse(backPackCache.value);
            backpack.setContents(savedBackpackData);
        } catch (e) {
            console.log(e)
        }
    }
    backpack.init();

};

export const clearCache = async function () {
    window.localStorage?.removeItem(storageKey);
}
