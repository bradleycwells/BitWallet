
<img width="1024" height="1024" alt="appIcon" src="https://github.com/user-attachments/assets/0052e55c-0192-4202-8d1c-de2c0e86febd" />

# BitWallet

A Bitcoin currency converter for iOS, built with SwiftUI and Swift Concurrency. Connects to the [Fixer API](https://fixer.io) to display live BTC exchange rates across multiple currencies, with price fluctuation indicators, persistent state, Firebase observability, and a clean MVVM architecture designed with production deployment in mind.

---

## Features

- **Live BTC Conversion** — Fetches exchange rates from Fixer and calculates converted values locally from a single BTC input
- **Multi-Currency Support** — Configurable currency selection (ZAR, USD, AUD, and many more); priority currencies are always surfaced first
- **Fluctuation Indicators** — Visual up/down arrow indicators showing whether each currency moved since yesterday, powered by the Fixer `/fluctuation` endpoint
- **Pull-to-Refresh** — Manual force-refresh bypasses the cache when needed
- **Persistent State** — BTC amount, selected currencies, onboarding status, and last fetch date all survive app restarts via `UserDefaults`
- **Welcome Onboarding Flow** — First-launch alert prompts for an initial BTC amount; the API is not called until a valid amount is set
- **Haptic Feedback** — Success haptics on BTC amount updates for tactile confirmation
- **Firebase Analytics** — Key user interactions are tracked with structured, typed events
- **Firebase Crashlytics** — Crash reporting configured for production monitoring
- **Unit & UI Tests** — Coverage across the ViewModel, service layer, cache manager, and key UI flows

---

## Architecture

The app follows **MVVM** with a clear separation of concerns across four layers:

```
App/
├── AppContainer.swift          # Dependency injection root (manual DI, no framework)
├── BitWalletApp.swift

Features/
└── Wallet/
    ├── Views/                  # Decomposed SwiftUI views (WalletView, Header, List, Row, etc.)
    ├── ViewModels/             # WalletViewModel — the single source of truth for wallet state
    ├── Models/                 # CurrencyValue, ExchangeRatesResponse, FluctuationResponse
    └── Services/               # DefaultFixerService + FixerService protocol

Core/
├── Analytics/                  # AnalyticsManager, AnalyticsEvent enum, AnalyticsService protocol
├── Data/Cache/                 # APIRateCacheManager — UserDefaults-backed response cache
├── Networking/                 # APIClient protocol + DefaultAPIClient (URLSession)
├── Repository/                 # UserDefaultsManager — typed persistence with protocol abstraction
├── Utils/                      # HapticManager, NumberFormatter extensions, DateProvider
└── Views/                      # Shared UI components (LogoView, WSSymbolText, WalletAlerts)

Config/
├── AppConfig.swift             # Reads API base URL + token from LocalConfig or environment variables
└── LocalConfigSample.plist     # Template for local secrets (not committed)
```

### Key Design Decisions

**Manual dependency injection via `AppContainer`** — All dependencies are composed at startup in a single container. This keeps `View` code free of environment assumptions and makes every dependency explicit and testable.

**Protocol-first service layer** — `FixerService`, `APIClient`, and `UserDefaultsManaging` are all defined as protocols. The `WalletViewModel` depends on abstractions, not concrete types. Swapping the underlying provider (e.g. a different exchange rate API) requires no changes to the ViewModel or Views.

**Local value calculation** — Exchange rates are fetched once from the API and stored. All currency conversion is done by multiplying locally (`rate * bitcoinAmount`). This means changing the BTC amount never triggers a network request, keeping API usage minimal.

**Swappable analytics** — `AnalyticsManager` delegates to an `AnalyticsService` protocol. The Firebase implementation is one concrete class. Replacing Firebase, adding a second provider, or mocking in tests requires no changes to call sites.

---

## API Strategy

The Fixer API has a limited request quota on the free plan. The following decisions were made deliberately to minimise consumption:

| Decision | Rationale |
|---|---|
| **API key sent via HTTP header** (`apikey`) | Required by Fixer; avoids key leakage in URLs and server logs |
| **24-hour cache via `APIRateCacheManager`** | Both `/latest` and `/fluctuation` responses are cached in `UserDefaults` keyed by endpoint + base + symbols. A fresh network call is only made if the cache is older than 24 hours or a force-refresh is triggered. |
| **Parallel fetch with `async let`** | The `latest` and `fluctuation` requests are dispatched concurrently in `WalletViewModel.fetchRates()`, halving the perceived latency for a two-request flow. |
| **Guard on BTC amount** | `fetchRates()` exits immediately if `bitcoinAmount == 0`. No API call is made on first launch until the user provides a valid amount. |
| **Local recalculation on amount change** | BTC amount changes call `calculateValues()` directly — no API round-trip. |
| **Fluctuation cache keyed by date range** | The fluctuation cache key includes the `start_date` and `end_date` so yesterday/today boundaries are respected without stale data. |

---

## Firebase Integration

**Analytics (`AnalyticsManager`)**

Events are defined as a typed Swift enum (`AnalyticsEvent`) with associated values where meaningful:

```swift
case editBtcAmountTapped(source: String)
case currencySelectionSaved(selectedCount: Int)
case currencyToggled(currencyCode: String, wasSelectedBefore: Bool)
// ...and more
```

This approach means every event is discoverable via autocomplete, the compiler catches typos, and adding/removing parameters is a single-location change. The `FirebaseAnalyticsService` is a `private` implementation detail — nothing outside the analytics layer imports `FirebaseAnalytics` directly.

**Crashlytics**

Configured via `FirebaseApp.configure()` in `AppContainer.init()`. Crashlytics runs automatically; no manual instrumentation was added beyond setup, as non-fatal error logging would be the natural next step in a production iteration.

---

## Persistence

All persistence is handled through `UserDefaultsManager`, which conforms to the `UserDefaultsManaging` protocol. Persisted values include:

| Key | Value |
|---|---|
| `com.bitwallet.btcAmount` | The user's BTC amount (Double) |
| `com.bitwallet.onboardingCompleted` | Whether the welcome flow has been seen (Bool) |
| `com.bitwallet.selectedCurrencies` | The user's chosen currency codes ([String]) |
| `com.bitwallet.lastFetchDate` | Timestamp of the last successful API fetch (Date) |

The `APIRateCacheManager` uses a separate, structured key namespace (`com.bitwallet.rates.<endpoint>.<base>.<symbols>`) so cache data is isolated from user preferences.

---

## Setup

### Prerequisites

- Xcode 15+
- iOS 15+ deployment target
- A [Fixer API](https://fixer.io) key

### Configuration

1. **Clone the repository**

2. **Create your local config**
   - Duplicate `BitWallet/Config/LocalConfigSample.plist` → rename to `LocalConfig.plist`
   - Fill in `API_BASE_URL` and `API_TOKEN` with your Fixer credentials
   - `LocalConfig.plist` is gitignored and never committed

   > **CI / GitHub Actions** — `API_TOKEN` is stored as a GitHub Actions [Environment Secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) and injected at build time via the `API_TOKEN` environment variable. `AppConfig.swift` reads this automatically; no `LocalConfig.plist` is needed in CI.

3. **Firebase**
   - The `GoogleService-Info.plist` in `BitWallet/Config/` is gitignored
   - Replace with your own from the Firebase console, or remove the Firebase SDK if not needed for local testing

4. **Build & Run**
   - Open `BitWallet.xcodeproj` in Xcode
   - Select a simulator or device running iOS 15+
   - Build and run (`⌘R`)

### Running Tests

```
⌘U  — Run all unit and UI tests from Xcode
```

---

## Production Readiness

The scope of this assessment is a functional prototype. The following outlines what I would address before shipping to production:

### Security
- [ ] Move the API key out of the app binary entirely — route requests through a lightweight server-side proxy that holds the secret, so the key is never exposed in the client
- [ ] Add certificate pinning for the Fixer API domain
- [ ] Audit `UserDefaults` for anything sensitive; migrate to Keychain if needed

### Observability
- [ ] Add non-fatal error logging to Crashlytics on network failures and decode errors, with context (endpoint, status code, currency symbol set)
- [ ] Add a Firebase Performance trace around the API fetch to track p50/p95 latency over time
- [ ] Set up Crashlytics alert thresholds for crash-free session rate

### Reliability
- [ ] Add retry logic with exponential backoff for transient network failures
- [ ] Gracefully degrade when the fluctuation endpoint is unavailable (show rates without indicators rather than failing the whole fetch)
- [ ] Cache invalidation strategy beyond 24 hours — consider time-zone-aware reset at midnight rather than a fixed interval

### CI/CD
- [ ] GitHub Actions pipeline: build → test → lint (SwiftLint) → archive
- [x] `API_TOKEN` stored as a GitHub Actions Environment Secret — injected at build time, never hardcoded or committed
- [x] Environment-targeted builds triggered via commit message tags — the pipeline reads the tag and selects the matching GitHub Environment, which injects the correct `.env` variables automatically:

  | Commit tag | GitHub Environment | Variables loaded |
  |---|---|---|
  | `[ios-prod]` | `ios-prod` | Production API token, base URL, Firebase config |
  | `[ios-qa]` | `ios-qa` | QA API token, base URL, Firebase config |
  | `[ios-dev]` | `ios-dev` | Dev API token, base URL, Firebase config |

  **Example:**
  ```
  git commit -m "feat: update currency row layout [ios-qa]"
  ```
  This triggers the QA workflow, injecting the `ios-qa` environment secrets without any manual config changes.

- [ ] Automated TestFlight deployment on merge to `main`

### Scalability
- [ ] Replace `UserDefaults`-based cache with a proper persistence layer (Core Data or SQLite via GRDB) if the currency list or history grows
- [ ] Support widget extension — the architecture's clean dependency graph makes this straightforward to add
- [ ] Localisation (`Localizable.strings`) — the app currently uses string literals throughout

---

## Trade-offs & Assumptions

- **UserDefaults for caching** — Chosen for simplicity and the small data footprint (a dictionary of ~5 exchange rates). For a production app with historical data or multiple base currencies, a database would be the appropriate choice.
- **Free Fixer plan constraints** — The free tier requires `BTC` as base currency and limits available endpoints. The architecture is base-currency agnostic; switching to a paid plan or a different provider requires no structural changes.
- **No Keychain storage** — The BTC amount is treated as non-sensitive. If the app were to store credentials or personally identifiable information, Keychain would be required.
- **Single-screen navigation** — Currency selection is presented as a sheet rather than a push navigation, which keeps the navigation stack shallow and the state management local to `WalletView`.

---

## 👨‍💻 Author

**Bradley Wells**  
Senior Mobile Developer | Mobile Architect  
Cape Town, South Africa

---

## 📄 License

This project is for assessment purposes.

