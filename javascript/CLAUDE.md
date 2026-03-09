# JavaScript Claude Plugin

JavaScript development tools and language server integration for Claude Code.

## Overview

This plugin provides comprehensive JavaScript development capabilities within Claude Code, including:

- **Language Server Integration**: Semantic code understanding via typescript-language-server
- **Development Tools**: ESLint, Prettier, build tools, and testing frameworks
- **Modern JavaScript Support**: ES6+, ES2020, JSX, React components
- **Command Line Tools**: Accessible via slash commands for common operations
- **MCP Integration**: Full language server capabilities through MCP protocol

## Features

### Semantic Code Understanding

- **TypeScript Language Server**: Excellent JavaScript and JSX support
- **Code Completion**: Intelligent autocomplete for modern JavaScript
- **Definition & References**: Navigate codebase semantically
- **Type Inference**: Understand JSDoc and inferred types
- **Error Detection**: Real-time syntax and type error detection

### Development Tools

- **ESLint Integration**: Code quality and style enforcement
- **Prettier Formatting**: Consistent code formatting
- **Build Tools**: Support for Webpack, Vite, Rollup, Babel
- **Testing**: Jest, Vitest, Mocha integration
- **Package Management**: npm/yarn support

### Framework Support

- **React**: JSX, hooks, component patterns
- **Vue.js**: Single-file components, reactivity
- **Angular**: TypeScript, decorators, modules
- **Node.js**: Server-side JavaScript, APIs
- **Vanilla JS**: Modern ECMAScript features

## Commands

### Linting

```bash
# Lint all JavaScript files
/javascript:cmd-lint

# Lint specific files
/javascript:cmd-lint src/components/Button.jsx

# Auto-fix issues
/javascript:cmd-lint --fix

# Quiet mode (errors only)
/javascript:cmd-lint --quiet
```

### Building

```bash
# Production build
/javascript:cmd-build

# Development build
/javascript:cmd-build --mode development

# Build with bundle analysis
/javascript:cmd-build --analyze

# Clean build
/javascript:cmd-build --clean
```

### Testing

```bash
# Run all tests
/javascript:cmd-test

# Run with coverage
/javascript:cmd-test --coverage

# Watch mode
/javascript:cmd-test --watch

# Test specific files
/javascript:cmd-test src/components/*.test.js
```

## MCP Integration

The plugin integrates with the javascript-dev MCP server providing:

- **definition**: Get symbol definitions
- **references**: Find all references
- **content**: Get code at specific locations
- **diagnostics**: Error and warning detection
- **hover**: Documentation and type information
- **rename_symbol**: Safe renaming
- **edit_file**: Precise code editing
- **completion**: Intelligent autocomplete
- **signature_help**: Function signatures

## Setup Requirements

### Environment

- Node.js 20+ installed
- JavaScript project with package.json
- MCP server running (javascript-dev service)

### Dependencies

```bash
# Core development tools
npm install --save-dev eslint prettier

# Testing framework
npm install --save-dev jest

# Build tools (choose based on project)
npm install --save-dev webpack  # or vite, rollup
```

### Configuration Files

#### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  extends: [
    'eslint:recommended'
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true
    }
  },
  rules: {
    // Custom rules
  }
};
```

#### Prettier Configuration

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

## Integration with Development Environment

This plugin works seamlessly with the local JavaScript development setup:

1. **Runtime**: Node.js local development environment with language server
2. **MCP Server**: HTTP bridge for language server communication
3. **Workspace**: Local project directory
4. **Tools**: Locally installed development tools and utilities

## Usage Examples

### React Component Development

Claude can understand and modify React components:

```jsx
// Before
function Button({ onClick, children }) {
  return <button onClick={onClick}>{children}</button>;
}

// After (Claude enhancement)
function Button({ onClick, children, variant = 'primary', disabled = false }) {
  const className = `btn btn-${variant} ${disabled ? 'disabled' : ''}`;

  return (
    <button
      className={className}
      onClick={onClick}
      disabled={disabled}
      aria-disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Code Quality Improvement

```javascript
// Before (potential issues)
function getData() {
  var data = fetch('/api/data');
  return data.json();
}

// After (Claude improvement)
async function getData() {
  try {
    const response = await fetch('/api/data');
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch data:', error);
    throw error;
  }
}
```

### Modern JavaScript Patterns

```javascript
// Claude suggests modern patterns
const API_CONFIG = {
  baseURL: 'https://api.example.com',
  timeout: 5000,
};

class ApiService {
  constructor(config = API_CONFIG) {
    this.config = config;
  }

  async request(endpoint, options = {}) {
    const url = `${this.config.baseURL}${endpoint}`;
    const response = await fetch(url, {
      timeout: this.config.timeout,
      ...options,
    });

    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`);
    }

    return response.json();
  }
}

// Usage
const api = new ApiService();
const data = await api.request('/users');
```

## Best Practices

### Code Organization

- Use clear file and directory structure
- Implement proper module boundaries
- Follow consistent naming conventions
- Separate concerns (UI, logic, data)

### Performance

- Implement lazy loading where appropriate
- Optimize bundle size
- Use React.memo/useMemo for expensive operations
- Monitor and optimize rendering performance

### Security

- Validate user inputs
- Sanitize data from external sources
- Use HTTPS for API calls
- Implement proper authentication

### Testing Best Practices

- Write unit tests for business logic
- Test component behavior and edge cases
- Implement integration tests
- Maintain good test coverage

## Troubleshooting

### Common Issues

**Language Server Not Responding**:

- Verify the javascript-dev MCP server process is running
- Verify MCP server connectivity
- Check workspace path configuration

**ESLint Configuration Errors**:

- Verify .eslintrc.js syntax
- Check for missing dependencies
- Ensure compatible plugin versions

**Build Failures**:

- Check package.json scripts
- Verify all dependencies installed
- Review build tool configuration

**Test Failures**:

- Check test environment setup
- Verify test configuration
- Review test dependencies

### Performance Issues

**Slow Language Server**:

- Use .gitignore to exclude large directories
- Limit workspace size
- Optimize file watching patterns

**Memory Usage**:

- Monitor local resource usage
- Optimize build configuration
- Use incremental builds

## Advanced Configuration

### Custom ESLint Rules

```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'plugin:react/recommended'
  ],
  rules: {
    'no-console': 'warn',
    'no-unused-vars': 'error',
    'prefer-const': 'error',
    'react/prop-types': 'off'
  }
};
```

### Custom Prettier Rules

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 4,
  "useTabs": false,
  "trailingComma": "none",
  "bracketSpacing": true
}
```

### Testing Configuration

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx}',
    '!src/**/*.test.{js,jsx}'
  ]
};
```

## Integration Examples

### With Claude Code MCP Tools

```javascript
// Claude can use MCP tools for precise operations
const userService = {
  // Get definition via MCP
  async getUser(id) {
    return fetch(`/api/users/${id}`).then(r => r.json());
  },

  // Find all references via MCP
  updateUser(id, data) {
    return fetch(`/api/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data)
    });
  }
};
```

### With Development Workflow

```bash
# Development workflow example
cd my-react-app

# 1. Write code with semantic understanding
# 2. Lint automatically
javascript:cmd-lint

# 3. Run tests
javascript:cmd-test --coverage

# 4. Build for production
javascript:cmd-build --analyze
```

This plugin provides a complete JavaScript development experience within Claude
Code, enabling intelligent code understanding, modern tooling integration, and
comprehensive support for JavaScript and React development.
