# Crash Fuzzer — platform reference

Launch the **real** build, fuzz realistic interactions, capture a replayable
crash. Always seed the RNG and log every action.

## iOS (simulator / device)
```bash
# Build & install the app on a booted simulator
xcodebuild -scheme App -configuration Release -destination 'generic/platform=iOS Simulator' build
xcrun simctl boot "iPhone 15"
xcrun simctl install booted <App.app>
xcrun simctl launch --console booted <bundle.id>
```
- Fuzz with an XCUITest random walk (seeded), or drive via `simctl` +
  accessibility. Deep links: `xcrun simctl openurl booted "<scheme>://..."`.
- Capture: crash logs in `~/Library/Logs/DiagnosticReports/`, `simctl spawn
  booted log stream`, `xcrun simctl io booted screenshot`.

## Android (emulator / device)
```bash
adb install -r app-release.apk
# Seeded monkey fuzz — realistic event mix, throttled
adb shell monkey -p <package> -s <seed> --throttle 150 \
  --pct-touch 40 --pct-motion 25 --pct-nav 15 --pct-majornav 10 \
  --pct-appswitch 5 -v 5000
adb logcat -d '*:E' > crash.log     # capture fatal exceptions / ANRs
adb exec-out screencap -p > shot.png
```

## Desktop (Electron / native)
- Launch the packaged app (not `dev`). Drive with the app's own automation
  (Spectron/Playwright-Electron) or OS-level UI automation; seed the action RNG.
- Capture: main + renderer logs, `crashReporter` dumps, stderr, exit code.

## Web
```js
// Playwright with a seeded pseudo-random driver against the real deployment
// (staging), not a mocked dev server.
const rng = mulberry32(SEED);
// pick from real affordances: click visible buttons/links, fill inputs,
// navigate, reload, toggle offline, resize — log every action taken.
```
- Capture: `page.on('pageerror')`, `console` errors, network failures, unhandled
  rejections, a trace (`context.tracing`) and screenshot on failure.

## CLI
- Fuzz argv, stdin, env, and file inputs with a seeded generator (empty, huge,
  non-UTF8, malformed). A crash = non-zero exit with a stack / panic, or a hang.
- Capture: full stderr, exit code, and the exact argv/stdin (the repro).

## Agent SDK
- Drive the real agent loop with fuzzed but plausible tool inputs / tool results
  / message sequences (malformed tool output, truncation, huge context,
  cancelled turns). A crash = an unhandled exception in the loop.
- Capture: the message/tool trace and the seed.

## Delta-debugging a repro
1. Record the full seeded action log up to the crash.
2. Bisect: drop the first/second half of the steps; keep whichever half still
   crashes. Repeat until every remaining step is load-bearing.
3. The minimized, still-crashing sequence + seed **is** the repro you ship.

## Truth table format
Enumerate the input/state classes around the crash — not just the one repro.
Show `Before` (on `main`) vs `After` (with the fix) for each:

| Scenario | Input / state | Before | After |
| --- | --- | --- | --- |
| the repro | seed 4211, steps 1–3 | 💥 crash | ✅ handled |
| empty input | "" | ✅ | ✅ |
| boundary | max length | 💥 crash | ✅ |
| happy path | typical | ✅ | ✅ |

The fix is only done when the repro row flips to ✅ and **no other row
regresses**.
