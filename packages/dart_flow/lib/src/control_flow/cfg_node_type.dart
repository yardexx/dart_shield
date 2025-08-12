enum CFGNodeType {
  entry,          // Function entry point
  exit,           // Function exit point
  statement,      // Statement
  condition,      // Conditional Expression
  loop,
  branch,
  call,           // Function/method call
  return_,        // Return statement
  throw_,         // Throw statement
  catch_,         // Catch statement
  continue_,      // Continue statement
  // merge,          // Merge point for multiple paths
}

// enum CFGNodeType {
//   entry,          // Function entry point
//   exit,           // Function exit point
//   statement,      // Regular statement
//   condition,      // Conditional expression (if, while, etc.)
//   merge,          // Merge point for multiple paths
//   call,           // Function/method call
//   throw_,         // Throw statement
//   return_,        // Return statement
//   break_,         // Break statement
//   continue_,      // Continue statement
// }
