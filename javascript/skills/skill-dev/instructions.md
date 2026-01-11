# JavaScript Development

## Configuration

`.eslintrc.js` should be in repository root for linting configuration.

## Standards

### ALWAYS

- Use modern JavaScript (ES6+) syntax
- Use `const` and `let` instead of `var`
- Use arrow functions for callbacks
- Use template literals for string interpolation
- Use async/await instead of callbacks or raw promises where appropriate

### NEVER

- Use `var` for variable declarations
- Leave unused variables or imports
- Use `==` instead of `===`
- Ignore linter warnings without good reason

## Common ESLint Fixes

| Rule | Issue | Fix |
| ---- | ----- | --- |
| no-unused-vars | Unused variable | Remove or prefix with `_` |
| no-console | Console statements | Remove or use logger |
| eqeqeq | Using == instead of === | Use === |
| no-var | Using var | Use const or let |
| prefer-const | Using let for constant | Use const |

## Package Management

### Using npm

```bash
npm install              # Install dependencies
npm install <package>    # Add new dependency
npm install -D <package> # Add dev dependency
npm test                # Run tests
npm run build           # Build project
```

### Using yarn

```bash
yarn install            # Install dependencies
yarn add <package>      # Add new dependency
yarn add -D <package>   # Add dev dependency
yarn test               # Run tests
yarn build              # Build project
```

## Testing

### Jest

Standard test framework for JavaScript projects.

```javascript
describe('Component', () => {
  it('should render correctly', () => {
    expect(component).toBeDefined();
  });
});
```

### Test Commands

```bash
/javascript:cmd-test                    # Run all tests
/javascript:cmd-test --coverage         # With coverage
/javascript:cmd-test --watch            # Watch mode
/javascript:cmd-test src/utils.test.js  # Specific file
```

## Linting

### ESLint

```bash
/javascript:cmd-lint                # Lint all files
/javascript:cmd-lint src/app.js    # Lint specific file
/javascript:cmd-lint --fix         # Auto-fix issues
```

### Common Configuration

`.eslintrc.js`:
```javascript
module.exports = {
  extends: ['eslint:recommended'],
  env: {
    node: true,
    es6: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
};
```

## Building

### Build Commands

```bash
/javascript:cmd-build                    # Production build
/javascript:cmd-build --mode development # Development build
```

## Best Practices

- Keep functions small and focused
- Use meaningful variable and function names
- Add JSDoc comments for public APIs
- Handle errors appropriately
- Avoid deeply nested code
- Use destructuring for cleaner code

## Module Patterns

### ES6 Modules (Preferred)

```javascript
// Export
export const myFunction = () => {};
export default MyClass;

// Import
import MyClass, { myFunction } from './module';
```

### CommonJS (Node.js)

```javascript
// Export
module.exports = { myFunction };

// Import
const { myFunction } = require('./module');
```
