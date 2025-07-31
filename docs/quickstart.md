# Quickstart

## Instalation

Install dart\_shield using:

```sh
dart pub global activate dart_shield
```

If you want to install specific version:

```sh
dart pub global activate dart_shield <version>
```

{% hint style="warning" %}
If this is your first CLI package, you might need to [setup PATH variable](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).
{% endhint %}

## Initialisation

In root of your Dart/Flutter project, initialise dart\_shield using:

```sh
dart_shield init
```

Initialisation command creates `shield_options.yaml` file in root of your project.

{% code title="After initialisation" %}
```
my_app/
├── bin/
├── lib/
├── test/
├── .gitignore
├── analysis_options.yaml
├── CHANGELOG.md
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── shield_options.yaml # New file
```
{% endcode %}

`shield_options.yaml` contains configuration used for analysis.

{% code title="shield_options.yaml" %}
```yaml
# dart_shield configuration file
# This file is used to configure analyser behavior.
# For more information, see [link]
shield:
  rules:
    - prefer-https-over-http
```
{% endcode %}

{% hint style="info" %}
More about analysis options here.
{% endhint %}

## Running Analysis

In root of your Dart/Flutter project, run analysis using:

```sh
dart_shield analyse <analyzed-folder>
```

Analysis then returns result to output:

{% code title="Analysis result" %}
```
=== [Analysis Summary] ===
📄 Files Analyzed: 1
❌ Critical Issues: 0
⚠️ Warnings: 0
ℹ️ Infos: 0

=== [File Reports] ===

>>> Analyzed File: lib/no_vulnerabilites.dart

🎉 No issues found!
```
{% endcode %}

{% hint style="info" %}
More about analysis reports and reporters here.
{% endhint %}
