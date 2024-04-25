/**
 * @license
 * Copyright 2023 Google LLC
 * SPDX-License-Identifier: Apache-2.0
 */

import * as Blockly from 'blockly';
import {blocks} from './blocks/json';
import '@blockly/toolbox-search';
import {jsonGenerator} from './generators/json';
import {save, load, clearCache} from './serialization';
import {toolbox} from './toolbox';
import {Backpack} from '@blockly/workspace-backpack';
import {ZoomToFitControl} from '@blockly/zoom-to-fit';
import {
    ScrollOptions,
    ScrollBlockDragger,
    ScrollMetricsManager,
} from '@blockly/plugin-scroll-options';

import './index.css';
// index.js
// Import Bootstrap CSS
// Importing Toastr CSS and JS
import 'toastr/build/toastr.min.css';
import toastr from 'toastr';

import 'bootstrap/dist/css/bootstrap.min.css';
// Import Bootstrap JavaScript
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import Swal from 'sweetalert2';

import {
    ContinuousToolbox,
    ContinuousFlyout,
    ContinuousMetrics,
} from '@blockly/continuous-toolbox';

// CommonJS
// Register the blocks with Blockly
Blockly.common.defineBlocks(blocks);

//set up toastr
toastr.options.showMethod = 'slideDown';
toastr.options.hideMethod = 'slideUp';
toastr.options.closeMethod = 'slideUp';

// Set up UI elements and inject Blockly
// const codeDiv = document.getElementById('generatedCode').firstChild;
const blocklyDiv = document.getElementById('blocklyDiv');
const codeDiv = document.getElementById('generatedCode');
const tb = document.getElementById('toolbox-categories');
const saveButton = document.getElementById('saveButton');
const clearCacheButton = document.getElementById('clearCacheButton');

const ws = Blockly.inject(blocklyDiv, {
    toolbox: toolbox,
    plugins: {
        // These are both required.
        blockDragger: ScrollBlockDragger,
        metricsManager: ScrollMetricsManager,
    },
    move: {
        wheel: true, // Required for wheel scroll to work.
    },
});
// Initialize plugin.
const backpack = new Backpack(ws);
const zoomToFit = new ZoomToFitControl(ws);
const scrollPlugin = new ScrollOptions(ws);
scrollPlugin.init();
zoomToFit.init();

// This function resets the code div and shows the
// generated code from the workspace.
const runCode = () => {
    const code = jsonGenerator.workspaceToCode(ws); //@todo
    const instructions = JSON.parse(`[${JSON.stringify(code)}]`)
    console.log(instructions);
    // codeDiv.innerText = code;
};


saveButton.onclick = ev => {
    const state = Blockly.serialization.workspaces.save(ws);
    const code = jsonGenerator.workspaceToCode(ws); //@todo
    const instructions = JSON.parse(`[${code}]`)
    console.log(instructions);
    const currentUrl = window.location.href;
    const myURLObj = new URL(currentUrl);
    var recipeId = myURLObj.searchParams.get('recipeId')

    Swal.fire({
        title: 'Are you sure?',
        text: "You won't be able to revert this!",
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, save it!'
    }).then((result) => {
        if (result.isConfirmed) {
            const state = Blockly.serialization.workspaces.save(ws);
            state.backpack = {}
            const data = {
                workspace: state,
                data: instructions
            }
            console.log(data)
            console.log('saving data')

            fetch(`http://localhost/api/recipe/recipe/${recipeId}/`, {
                headers: {"Content-Type": "application/json; charset=utf-8"},
                method: 'POST',
                body: JSON.stringify(data)
            }).then(r => {
                Swal.fire(
                    'Saved!',
                    'Your file has been saved.',
                    'success'
                );
            });

            save(ws, backpack);


        }
    })
}

// Load the initial state from storage and run the code.
load(ws, backpack).then(value => {
});

runCode();
clearCacheButton.onclick = ev => {
    clearCache();
}


// // Every time the workspace changes state, save the changes to storage.
// ws.addChangeListener((e) => {
//     if (e.isUiEvent) return;
//     save(ws, backpack);
// });

ws.addChangeListener((e) => {
    if (
        e.isUiEvent || e.type === Blockly.Events.FINISHED_LOADING ||
        ws.isDragging()
    ) {
        return;
    }
    runCode();
});

