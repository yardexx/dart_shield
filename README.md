<h1 align="center">dart_shield</h1>

<div align="center">
    <picture>
        <img
        alt="Dart Shield"
        src="https://github.com/yardexx/dart_shield/blob/master/resources/img/shield-logo.svg"
        width="150"
        >
    </picture>
    <p>Dart-based security-focused code analyzer which analyzes your Dart code for potential security flaws.</p>
    <a href="https://github.com/yardexx/dart_shield/actions/workflows/dart.yml"><img src="https://github.com/yardexx/dart_shield/actions/workflows/dart.yml/badge.svg" alt="Pipelines: GitHub Actions"/></a>
    <a href="https://codecov.io/gh/yardexx/dart_shield"><img src="https://codecov.io/gh/yardexx/dart_shield/branch/master/graph/badge.svg" alt="Coverage"/></a>
    <a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="Style: Very Good Analysis"></a>
    <a href="https://www.gitbook.com/preview?utm_source=gitbook_readme_badge&utm_medium=organic&utm_campaign=preview_documentation&utm_content=link"><img src="https://img.shields.io/static/v1?message=Documented%20on%20GitBook&logo=gitbook&logoColor=ffffff&label=%20&labelColor=5c5c5c&color=3F89A1"/>
</a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</div>


> 🚧 UNDER CONSTRUCTION 🚧
>
> Please note that this project is still under construction and not yet ready for production use.
>
> Full documentation will be available once the project is ready for production use. If you have
> any questions, feel free to open an issue.

# Overview

dart_shield CLI is heavily inspired by other Dart and Flutter CLI, so commands and their behaviour
is similar to what you might expect.

# Features

`dart_shield` can detect the following security issues:

- Hardcoded API keys
- Hardcoded URLs
- Weak hashing algorithms
- Usage of non-secure random number generators
- Usage of insecure HTTP connections

# Installation
To install dart_shield, run the following command:

```bash
# Using pub.dev
dart pub global activate dart_shield

# Directly from GitHub
dart pub global activate -s git https://github.com/yardexx/dart_shield
```

# Usage

dart_shield contains two crucial commands:

- `init` - Initializes dart_shield in your project.
- `analyze` - Analyzes your Dart code for potential security flaws.

To initialize `dart_shield` in your project, run the following command:

```bash
dart_shield init
```

This command updates your `analysis_options.yaml` file to include the `dart_shield` configuration.
If the `dart_shield` section already exists and you want to recreate it, use the `-f` or `--force` flag:

```bash
dart_shield init -f
# or
dart_shield init --force
```

To analyze your Dart code for potential security flaws, run the following command:

```bash
# Analyze current directory (default)
dart_shield analyze

# Or explicitly specify a directory
dart_shield analyze .
dart_shield analyze lib
```

This command analyzes your Dart code for security issues.

# Configuration

Configuration is done through your `analysis_options.yaml` file using the `dart_shield` key.
This approach follows Dart conventions and keeps all analysis configuration in one place.

Example configuration in `analysis_options.yaml`:

```yaml
# Enable dart_shield as an analyzer plugin
analyzer:
  plugins:
    - dart_shield

# dart_shield configuration
dart_shield:
  analyzers:
    code: true  # Enable code analysis

  # Future options:
  # exclude:
  #   - 'lib/generated/**'
  #   - '**.g.dart'
```

# Rules

dart_shield includes a set of predefined rules to analyze Dart code for potential security flaws,
similar to how linter rules enforce code style.

## List of rules

- avoid_hardcoded_secrets: Detects hardcoded secrets, such as API keys and passwords.
- avoid_hardcoded_urls: Detects hardcoded URLs.
- prefer_https_over_http: Detects the use of insecure HTTP connections.
- avoid_weak_hashing: Detects the use of weak hashing algorithms, such as MD5 and SHA-1.
- prefer_secure_random: Detects the use of non-secure random number generators.

# Contributing

This project is still under construction, so contributions might be limited. However, one of the
main goals of this project is to provide a free, open-source tool for the community, emphasizing
the importance of security accessibility.

Once the project is production-ready, contributions will be welcome.

If you have any ideas, suggestions, or wish to contribute, feel free to open an issue.

# License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
