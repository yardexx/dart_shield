// ignore_for_file: unused_local_variable

// This file contains some security vulnerabilities, but since we've excluded
// this file in `shield_options.yaml`, dart_shield will ignore these violations
// and won't report them.
void unsafeFunction() {
  // Violation: Using `http` constructor instead of `https`
  final unsafeUri = Uri.http('example.com', 'path');
}
