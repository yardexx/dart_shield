# Dart Shield Test Reorganization Plan

## Overview
This plan outlines the complete reorganization of the dart_shield test suite, moving from the current basic structure to a comprehensive, well-organized testing strategy that covers unit tests, integration tests, and end-to-end tests.

## Current State Analysis

### ✅ Existing Tests (Well Covered)
- **Configuration**: `ShieldConfig`, `GlobConverter`, `LintRuleConverter` - comprehensive coverage
- **Utils**: `yamlToDartMap`, `Suppression` - thorough testing  
- **Rules**: Only `PreferSecureRandom` has tests - well-structured with AST analysis

### ❌ Missing Tests (Critical Gaps)
- **CLI Commands**: 0% coverage (AnalyzeCommand, InitCommand, ShieldCommandRunner)
- **Security Rules**: 80% missing (AvoidHardcodedSecrets, PreferHttpsOverHttp, AvoidHardcodedUrls, AvoidWeakHashing)
- **Core Security Analyzer**: 0% coverage (SecurityAnalyzer, Workspace, RuleRegistry)
- **Report System**: 0% coverage (ProjectReport, FileReport, ConsoleReport)
- **Models and Enums**: 0% coverage (RuleId, Severity, RuleStatus, MatchingPattern, ShieldSecrets, LintIssue)
- **Extensions and Utilities**: 0% coverage (SourceSpanX extension)

## New Directory Structure

```
test/
├── unit/                          # Fast, isolated unit tests
│   ├── cli/
│   │   ├── commands/
│   │   │   ├── analyze_command_test.dart
│   │   │   ├── init_command_test.dart
│   │   │   └── shield_command_test.dart
│   │   └── command_runner_test.dart
│   ├── security_analyzer/
│   │   ├── configuration/
│   │   │   ├── shield_config_test.dart (moved)
│   │   │   ├── glob_converter_test.dart (moved)
│   │   │   └── lint_rule_converter_test.dart (moved)
│   │   ├── rules/
│   │   │   ├── rule_registry_test.dart
│   │   │   ├── enums/
│   │   │   │   ├── rule_id_test.dart
│   │   │   │   ├── severity_test.dart
│   │   │   │   └── rule_status_test.dart
│   │   │   ├── models/
│   │   │   │   ├── matching_pattern_test.dart
│   │   │   │   ├── shield_secrets_test.dart
│   │   │   │   └── lint_issue_test.dart
│   │   │   ├── rules_list/
│   │   │   │   ├── avoid_hardcoded_secrets_test.dart
│   │   │   │   ├── avoid_hardcoded_urls_test.dart
│   │   │   │   ├── prefer_https_over_http_test.dart
│   │   │   │   ├── crypto/
│   │   │   │   │   ├── avoid_weak_hashing_test.dart
│   │   │   │   │   └── prefer_secure_random_test.dart (moved)
│   │   │   └── lint_rule_test.dart
│   │   ├── report/
│   │   │   ├── analysis_report/
│   │   │   │   ├── file_report_test.dart
│   │   │   │   └── project_report_test.dart
│   │   │   └── reporters/
│   │   │       ├── console_report_test.dart
│   │   │       └── issue_reporter_test.dart
│   │   ├── security_analyzer_test.dart
│   │   ├── workspace_test.dart
│   │   ├── extensions_test.dart
│   │   └── utils/
│   │       └── suppression_test.dart (moved)
│   └── utils/
│       └── yaml_test.dart (moved)
├── integration/                   # Component integration tests
│   ├── cli_integration_test.dart
│   ├── config_loading_test.dart
│   └── rule_execution_test.dart
├── e2e/                          # End-to-end tests
│   ├── analyze_command_e2e_test.dart
│   ├── init_command_e2e_test.dart
│   └── full_analysis_e2e_test.dart
├── fixtures/                     # Test data and fixtures
│   ├── dart_files/
│   │   ├── vulnerable_code.dart
│   │   ├── secure_code.dart
│   │   └── mixed_code.dart
│   ├── configs/
│   │   ├── minimal_config.yaml
│   │   ├── complete_config.yaml
│   │   └── invalid_config.yaml
│   └── expected_outputs/
└── helpers/                      # Test utilities
    ├── test_analyzer.dart
    ├── mock_workspace.dart
    └── test_data_builder.dart
```

## Implementation Phases

### Phase 1: Directory Structure & Test Migration (Priority: High)
1. Create new directory structure
2. Move existing tests to appropriate locations
3. Update import paths in moved tests
4. Verify existing tests still pass

### Phase 2: Core Infrastructure Tests (Priority: High)
1. **Enums**: RuleId, Severity, RuleStatus
2. **Models**: MatchingPattern, ShieldSecrets, LintIssue
3. **Core Components**: SecurityAnalyzer, Workspace, RuleRegistry
4. **Extensions**: SourceSpanX extension

### Phase 3: Security Rules Tests (Priority: High)
1. **AvoidHardcodedSecrets** - Most critical security rule
2. **PreferHttpsOverHttp** - Common vulnerability
3. **AvoidWeakHashing** - Crypto security
4. **AvoidHardcodedUrls** - Configuration security

### Phase 4: CLI Commands Tests (Priority: Medium)
1. **AnalyzeCommand** - Core functionality
2. **InitCommand** - Configuration setup
3. **ShieldCommandRunner** - Error handling
4. **ShieldCommand** base class - Workspace validation

### Phase 5: Reporting System Tests (Priority: Medium)
1. **FileReport** - Issue categorization
2. **ProjectReport** - Project-level reporting
3. **ConsoleReport** - Output formatting
4. **IssueReporter** - Issue display

### Phase 6: Integration Tests (Priority: Medium)
1. **CLI Integration** - Command execution with real configs
2. **Config Loading** - Configuration file handling
3. **Rule Execution** - Rule execution with real AST analysis

### Phase 7: End-to-End Tests (Priority: Low)
1. **Analyze Command E2E** - Complete analysis workflow
2. **Init Command E2E** - Configuration initialization workflow
3. **Full Analysis E2E** - Complete project analysis

### Phase 8: Test Helpers & Fixtures (Priority: Low)
1. **Test Analyzer** - AST analysis utilities
2. **Mock Workspace** - Workspace mocking utilities
3. **Test Data Builder** - Test data generation
4. **Fixtures** - Sample code and configurations

## Test Categories Explained

### Unit Tests (`test/unit/`)
- **Purpose**: Test individual components in isolation
- **Characteristics**: Fast, no I/O, mocked dependencies
- **Examples**: Rule logic validation, configuration parsing, enum conversions

### Integration Tests (`test/integration/`)
- **Purpose**: Test component interactions
- **Characteristics**: Medium speed, limited I/O, real dependencies
- **Examples**: CLI command execution with real configs, rule execution with real AST

### End-to-End Tests (`test/e2e/`)
- **Purpose**: Test complete user workflows
- **Characteristics**: Slower, full I/O, real file system
- **Examples**: Full analysis of sample projects, CLI command execution from start to finish

## Testing Best Practices

### 1. AST Testing Pattern
Follow the existing `PreferSecureRandom` test pattern:
- Create temporary files with test code
- Use `AnalysisContextCollection` for AST analysis
- Test both positive and negative cases
- Verify rule properties (ID, severity, message)

### 2. Mock External Dependencies
- Use mocks for file system operations
- Mock logger for CLI tests
- Mock analysis context for isolated testing

### 3. Test Data Builders
Create helper classes for building test data:
- `TestDataBuilder` for creating test Dart files
- `ConfigBuilder` for creating test configurations
- `IssueBuilder` for creating test issues

### 4. Parameterized Tests
Use `test` with multiple scenarios:
- Test different rule configurations
- Test various error conditions
- Test edge cases and boundary conditions

### 5. Error Case Coverage
Test invalid inputs and edge cases:
- Invalid configuration files
- Malformed Dart code
- Missing dependencies
- Permission errors

## Success Metrics

### Coverage Goals
- **Unit Tests**: 90%+ line coverage for core components
- **Integration Tests**: 80%+ coverage for component interactions
- **E2E Tests**: 100% coverage for critical user workflows

### Quality Goals
- All tests pass consistently
- Tests run in under 30 seconds for unit tests
- Tests are maintainable and well-documented
- Tests catch regressions effectively

## Implementation Timeline

### Week 1: Foundation
- Create directory structure
- Move existing tests
- Implement enum and model tests

### Week 2: Core Components
- Implement SecurityAnalyzer tests
- Implement Workspace tests
- Implement RuleRegistry tests

### Week 3: Security Rules
- Implement all missing rule tests
- Create test fixtures
- Implement rule-specific test helpers

### Week 4: CLI & Reporting
- Implement CLI command tests
- Implement reporting system tests
- Create integration tests

### Week 5: E2E & Polish
- Implement end-to-end tests
- Create comprehensive test helpers
- Documentation and cleanup

## Risk Mitigation

### Technical Risks
- **AST Analysis Complexity**: Use existing patterns and helper functions
- **File System Dependencies**: Use proper mocking and temporary files
- **Test Performance**: Optimize test execution and use appropriate test categories

### Process Risks
- **Test Maintenance**: Create clear documentation and patterns
- **Coverage Gaps**: Regular coverage analysis and gap identification
- **Regression Detection**: Comprehensive test scenarios and edge cases

## Conclusion

This reorganization will transform dart_shield from having basic test coverage to having comprehensive, well-organized test coverage that ensures code quality, catches regressions, and provides confidence in the security analysis capabilities of the tool.

The phased approach ensures that critical components are tested first, while maintaining the existing functionality and gradually building up comprehensive test coverage across all components.
