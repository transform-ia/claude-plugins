# JavaScript Development

## Standards

### NEVER

- Use `var` for variable declarations — use `const` or `let`
- Use `==` instead of `===`
- Leave unused variables or imports
- Ignore linter warnings without good reason
- Use callback-based patterns when async/await is available

### ALWAYS

- Use modern JavaScript (ES6+) syntax
- Use arrow functions for callbacks
- Use template literals for string interpolation
- Use async/await for asynchronous operations
- Use destructuring for cleaner code
- Keep functions small and focused
- Use meaningful variable and function names

## MCP Tools (JavaScript Language Server)

Prefer MCP tools over grep — they understand JavaScript semantics:

```text
mcp__javascript-dev__definition   - Go to definition
mcp__javascript-dev__references   - Find all references
mcp__javascript-dev__hover        - Type information
mcp__javascript-dev__diagnostics  - Errors and warnings
```

## Package Management

Use npm by default. Use yarn only if `yarn.lock` already exists in the project.

```bash
npm install              # Install dependencies
npm install <package>    # Add new dependency
npm install -D <package> # Add dev dependency
npm test                 # Run tests
npm run build            # Build project
```

## ESLint Configuration

Modern ESLint (v9+) uses flat config (`eslint.config.js`). Legacy `.eslintrc.*`
files are still supported but deprecated.

### Flat Config (eslint.config.js — preferred for new projects)

```javascript
import js from '@eslint/js';

export default [
  js.configs.recommended,
  {
    rules: {
      'no-unused-vars': 'warn',
      'no-console': 'warn',
      eqeqeq: 'error',
      'prefer-const': 'error',
    },
  },
];
```

### Legacy Config (.eslintrc.js — for existing projects)

```javascript
module.exports = {
  env: {
    browser: true,
    es2022: true,
    node: true,
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: { jsx: true },
  },
  plugins: ['react'],
};
```

## Common ESLint Fixes

| Rule              | Issue                    | Fix                        |
| ----------------- | ------------------------ | -------------------------- |
| `no-unused-vars`  | Unused variable          | Remove or prefix with `_`  |
| `no-console`      | Console statement        | Remove or use logger       |
| `eqeqeq`          | Using `==` instead of `===` | Use `===`               |
| `no-var`          | Using `var`              | Use `const` or `let`       |
| `prefer-const`    | Using `let` for constant | Use `const`                |

## Module Patterns

### ES6 Modules (preferred for browser and modern Node.js)

```javascript
// Export
export const myFunction = () => {};
export default MyClass;

// Import
import MyClass, { myFunction } from './module.js';
```

### CommonJS (Node.js legacy)

```javascript
// Export
module.exports = { myFunction };

// Import
const { myFunction } = require('./module');
```

## Testing

Use Vitest for new projects (faster, ESM-native). Use Jest for projects that
already have it configured.

```javascript
// Vitest
import { describe, it, expect, vi } from 'vitest';

describe('MyModule', () => {
  it('should return expected value', () => {
    expect(myFunction('input')).toBe('expected');
  });
});
```

## React Patterns

- Use functional components with hooks (never class components for new code)
- Use PropTypes for prop validation in plain JS (or migrate to TypeScript)
- Co-locate component files and their tests

```javascript
import PropTypes from 'prop-types';

function Button({ onClick, children, variant = 'primary' }) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick}>
      {children}
    </button>
  );
}

Button.propTypes = {
  onClick: PropTypes.func,
  children: PropTypes.node.isRequired,
  variant: PropTypes.string,
};

export default Button;
```

## Troubleshooting

### ESLint configuration errors

- For flat config: check `eslint.config.js` syntax, ensure `@eslint/js` is installed
- For legacy: verify `.eslintrc.js` syntax, check for missing dependencies
- Run `/javascript:cmd-lint --fix` to auto-fix what ESLint can

### "Module not found" errors

Check `package.json` for the dependency, run `npm install`, verify import paths
use the correct extension (`.js` required for ES modules).

### Language server not responding

Verify the `javascript-dev` MCP server process is running. Check `.mcp.json`
for correct configuration. Restart MCP server if needed.
