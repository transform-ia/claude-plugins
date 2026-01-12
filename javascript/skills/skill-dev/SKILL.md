---
name: skill-dev
description: |
  JavaScript development tools and language server integration.

  Auto-activates when working with *.js, *.jsx, *.mjs, *.cjs, package.json files.

  DO NOT activate when:
  - Working with TypeScript files (use typescript plugin)
  - Working with Dockerfiles, Helm charts, or YAML files
  - User is doing Docker, Helm, or infrastructure work

  ## Slash Commands vs Skills

  **Slash Commands** (`/javascript:cmd-*`): Single-operation wrappers for specific tasks:
  - `/javascript:cmd-lint` - Run ESLint on JavaScript files
  - `/javascript:cmd-build` - Build JavaScript applications
  - `/javascript:cmd-test` - Run JavaScript tests

  **Skills** (`javascript:skill-dev`): Extended context for complex workflows involving:
  - Writing/editing JavaScript/React source code
  - Multi-file refactoring
  - Feature implementation
  - Component creation
  - Using MCP tools for semantic navigation (definition, references, etc.)

  Use slash commands for build/test/lint operations. The skill auto-activates when modifying JavaScript code.
allowed-tools:
  Read, Write(*.js, *.jsx, *.mjs, *.cjs, package.json),
  Edit(*.js, *.jsx, *.mjs, *.cjs, package.json), Glob, Grep,
  Bash(npm, yarn, node), SlashCommand(/javascript:*), mcp__javascript-dev__*
---

The `javascript:skill-dev` skill provides JavaScript development capabilities for Claude Code, optimized for React and modern JavaScript projects.

## Overview

This skill enables Claude Code to work with JavaScript projects using modern development tools and best practices. It integrates with the JavaScript development environment (javascript-image) to provide semantic code understanding, linting, formatting, and build capabilities.

## Key Capabilities

### Code Analysis & Navigation
- **Semantic Understanding**: Uses typescript-language-server for deep JavaScript comprehension
- **Code Completion**: Intelligent autocomplete for JavaScript, JSX, and modern ES6+ syntax
- **Definition & References**: Navigate to function definitions and find all references
- **Type Inference**: Understand JSDoc types and infer types in JavaScript code
- **Error Detection**: Identify syntax errors, unused variables, and potential issues

### Code Quality & Formatting
- **ESLint Integration**: Enforce code quality standards and catch common issues
- **Prettier Formatting**: Consistent code formatting and style
- **Modern JavaScript**: Support for ES6+, ES2020, and latest JavaScript features
- **React/JSX Support**: Specialized understanding for React components and JSX syntax

### Build & Development Tools
- **Build Integration**: Support for modern build tools (Webpack, Vite, Rollup)
- **Package Management**: npm/yarn package.json management and dependency analysis
- **Testing Frameworks**: Integration with Jest, Vitest, and other testing tools
- **Babel Transpilation**: Support for modern JavaScript syntax compilation

## Typical Use Cases

### React Development
```bash
# Analyze React component structure
/javascript:skill-dev Understand React component at src/components/Button.jsx

# Add PropTypes or convert to TypeScript
/javascript:skill-dev Add type definitions to React component

# Optimize React component performance
/javascript:skill-dev Optimize React component for performance
```

### JavaScript Project Setup
```bash
# Initialize new JavaScript project with best practices
/javascript:skill-dev Set up JavaScript project with modern tooling

# Configure ESLint and Prettier for project
/javascript:skill-dev Configure linting and formatting

# Set up testing framework
/javascript:skill-dev Configure Jest testing setup
```

### Code Refactoring
```bash
# Modernize legacy JavaScript code
/javascript:skill-dev Modernize JavaScript code to ES6+

# Extract reusable components
/javascript:skill-dev Extract React component from larger file

# Optimize performance bottlenecks
/javascript:skill-dev Analyze and optimize JavaScript performance
```

### Build & Deployment
```bash
# Build JavaScript application
/javascript:skill-dev Build production version of application

# Optimize bundle size
/javascript:skill-dev Analyze and optimize bundle size

# Configure deployment settings
/javascript:skill-dev Set up deployment configuration
```

## Integration with Development Environment

This skill works seamlessly with the javascript-image container:

1. **Language Server**: Uses typescript-language-server with excellent JavaScript support
2. **MCP Bridge**: Communicates via mcp-language-server over HTTP
3. **Development Tools**: Access to ESLint, Prettier, and modern JavaScript tooling
4. **Workspace Integration**: Works with mounted workspace volumes

## Available Commands

The skill provides specialized commands for JavaScript development:

- `/javascript:cmd-lint` - Run ESLint on JavaScript files
- `/javascript:cmd-build` - Build JavaScript applications
- `/javascript:cmd-test` - Run JavaScript tests

## Configuration

### Project Setup
Configure your JavaScript project for optimal development:

```json
// package.json
{
  "name": "my-project",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "test": "vitest",
    "lint": "eslint src --ext .js,.jsx",
    "format": "prettier --write src/**/*.{js,jsx}"
  },
  "devDependencies": {
    "eslint": "^8.57.0",
    "prettier": "^3.1.1",
    "vite": "^5.0.0"
  }
}
```

### ESLint Configuration
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
  plugins: ['react'],
  rules: {
    // Custom rules for code quality
  }
}
```

### Prettier Configuration
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

## Best Practices Supported

### Modern JavaScript
- Use ES6+ features (arrow functions, destructuring, template literals)
- Implement proper error handling with try/catch
- Use async/await for asynchronous operations
- Follow functional programming principles where applicable

### React Development
- Use functional components with hooks
- Implement proper component composition
- Use PropTypes or TypeScript for prop validation
- Follow React best practices for performance

### Code Organization
- Use clear file naming conventions
- Implement proper module structure
- Keep components small and focused
- Use consistent import/export patterns

## Troubleshooting

### Common Issues

**Language Server Not Responding**:
- Check javascript-dev pod status
- Verify workspace mounting
- Check MCP server connectivity

**ESLint Configuration Errors**:
- Verify .eslintrc.js syntax
- Check for missing dependencies
- Ensure compatible ESLint version

**Build Failures**:
- Check package.json scripts
- Verify all dependencies are installed
- Review build tool configuration

### Performance Optimization

**Slow Language Server**:
- Limit workspace size with .gitignore
- Exclude large node_modules directories
- Use project-specific tsconfig.json/jsconfig.json

**Memory Issues**:
- Monitor container resource usage
- Optimize build configuration
- Use incremental builds when possible

## Integration Examples

### With Claude Code

```javascript
// Claude can understand and modify React components
function Button({ onClick, children, variant = 'primary' }) {
  const className = `btn btn-${variant}`;
  return (
    <button className={className} onClick={onClick}>
      {children}
    </button>
  );
}
```

Claude can:
- Understand component props and default values
- Suggest accessibility improvements
- Add TypeScript definitions
- Optimize component performance
- Refactor for better reusability

### With MCP Tools

The skill provides access to MCP tools for:
- **Content Analysis**: Get code at specific locations
- **Symbol Navigation**: Find definitions and references
- **Code Completion**: Intelligent autocomplete
- **Error Detection**: Real-time error highlighting
- **Refactoring**: Safe code modifications

## Advanced Features

### Custom Configurations
Support for project-specific configurations:
- Custom ESLint rules
- Project-specific Prettier settings
- Custom build configurations
- Framework-specific optimizations

### Multi-framework Support
While optimized for React, also supports:
- Vue.js applications
- Angular projects
- Vanilla JavaScript
- Node.js applications
- Next.js applications

### Development Workflow
Integrates with modern development workflows:
- Hot Module Replacement (HMR)
- Watch mode for development
- Continuous integration support
- Deployment automation

This skill provides a comprehensive JavaScript development experience within Claude Code, enabling intelligent code understanding, modern tooling integration, and best practice enforcement for JavaScript and React projects.
