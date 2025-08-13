const jestPlugin = require('eslint-plugin-jest');
const globals = require('globals');

module.exports = [
    // LWC specific configuration with decorator support
    {
        files: ['**/lwc/**/*.js'],
        languageOptions: {
            ecmaVersion: 'latest',
            sourceType: 'module',
            globals: {
                ...globals.browser,
                ...globals.es2021
            },
            parser: require('@babel/eslint-parser'),
            parserOptions: {
                requireConfigFile: false,
                babelOptions: {
                    presets: ['@babel/preset-env'],
                    plugins: [
                        ['@babel/plugin-proposal-decorators', { legacy: true }]
                    ]
                }
            }
        },
        rules: {
            'no-unused-vars': 'warn',
            'no-console': 'warn',
            'no-debugger': 'error'
        }
    },

    // Test files configuration
    {
        files: ['**/*.test.js', '**/*.spec.js'],
        languageOptions: {
            ecmaVersion: 'latest',
            sourceType: 'module',
            globals: {
                ...globals.node,
                ...globals.es2021,
                ...jestPlugin.environments.globals.globals
            }
        },
        plugins: {
            jest: jestPlugin
        },
        rules: {
            'no-unused-vars': 'warn',
            'no-console': 'warn'
        }
    }
];
