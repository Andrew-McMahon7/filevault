import globals from 'globals';
import pluginJs from '@eslint/js';

export default [
    { files: ['**/*.js'], languageOptions: { sourceType: 'module' } },
    { languageOptions: { globals: { ...globals.browser, ...globals.node, ...globals.mocha } } },
    pluginJs.configs.recommended,
    {
        ignores: ['*/*.test.js'],
    },
];