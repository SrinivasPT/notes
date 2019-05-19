# Message Priorities/Levels
It is important to ensure that log message are appropriate in content and severity. The following guidelines are suggested:

### fatal
Severe errors that cause premature termination. Expect these to be immediately visible on a status console. See also Internationalization.

### error 
Other runtime errors or unexpected conditions. Expect these to be immediately visible on a status console. See also Internationalization.

### warn
Use of deprecated APIs, poor use of API, 'almost' errors, other runtime situations that are undesirable or unexpected, but not necessarily "wrong". Expect these to be immediately visible on a status console. See also Internationalization.

### info
Interesting runtime events (startup/shutdown). Expect these to be immediately visible on a console, so be conservative and keep to a minimum. See also Internationalization.

### debug
Detailed information on the flow through the system. Expect these to be written to logs only.

### trace
More detailed information. Expect these to be written to logs only.
