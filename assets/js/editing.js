import {
  editor as monaco,
  Range as Range
} from '../vendor/monaco/vs/editor/editor.api';

import '../vendor/monaco/vs/basic-languages/elixir/elixir.contribution.js';
import "../css/editing.css"
import { initTablexEditors } from 'tablex_view';

function initEditor() {
  const textarea = document.getElementById('raw-code');
  const node = document.getElementById('new-rev-editor');

  const editor = monaco.create(node, {
    value: textarea.value,
    language: 'elixir',
    lineNumbers: 'on',
    readOnly: false,
    glyphMargin: true,
    scrollBeyondLastLine: false,
    wordWrap: 'on',
    wrappingStrategy: 'advanced',
    minimap: {
      enabled: false
    },
    overviewRulerLanes: 0
  });

  editor.onDidChangeModelContent(() => {
    const value = editor.getValue()
    textarea.value = value;

    if (value) {
      textarea.dispatchEvent(
        new Event("change", {bubbles: true, cancelable: true})
      );
    }
  });

  window.addEventListener("phx:error", evt => displayErrors(evt, editor));

  window.destroyEditor = () => {
    editor.dispose();
  };

  window.addEventListener('resize', () => {
    editor.layout({
      width: node.parentNode.offsetWidth,
      height: node.parentNode.offsetHeight
    });
  });

  return editor;
}

function displayErrors(evt, editor) {
  const codeErrors = evt.detail.code;
  const decorations = getDecorations(codeErrors);

  this.decorations = editor.deltaDecorations(
    this.decorations || [],
    decorations
  );
}

function getDecorations(errors) {
  if (!errors || errors == [] || errors == {}) {
    return [];
  }

  const [error] = errors;

  if (error && error.pos) {
    const {pos} = error;
    return [
        {
          range: new Range(pos.line, 1, pos.line, 1),
          options: {
            isWholeLine: true,
            linesDecorationsClassName: 'line-code-error'
          }
        }
      ];
  }

  return [];
}

function initTablexEditor() {
  initTablexEditors();

  document.addEventListener('tablex:update', evt => {
    const tablex = evt.detail.data;
    const textarea = document.getElementById('raw-code');
    textarea.value = tablex;
  });
}

document.addEventListener('DOMContentLoaded', () => {
  initEditor();
  initTablexEditor();
});
