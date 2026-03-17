import Foundation
import FirebaseAnalytics

// MARK: - Protocol

/// Defines the interface for logging analytics events.
/// Swap the underlying implementation in `AnalyticsManager.shared` without
/// touching any call site.
protocol AnalyticsService {
    func log(_ event: AnalyticsEvent)
}

// MARK: - Events

enum AnalyticsEvent {
    // Wallet Header
    case editBtcAmountTapped(source: String)

    // Wallet View
    case addCurrencyButtonTapped
    case welcomeAlertGetStarted
    case welcomeAlertMaybeLater
    case editAmountAlertSaved

    // Currency Selection
    case currencySelectionCancelled
    case currencySelectionSaved(selectedCount: Int)
    case currencyToggled(currencyCode: String, wasSelectedBefore: Bool)
}

// MARK: - Manager

/// Single access point for analytics throughout the app.
/// Replace `service` with any `AnalyticsService` implementation to swap providers.
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    var service: AnalyticsService = FirebaseAnalyticsService()

    private init() {}

    func log(_ event: AnalyticsEvent) {
        service.log(event)
    }
}

// MARK: - Firebase Implementation

private final class FirebaseAnalyticsService: AnalyticsService {
    func log(_ event: AnalyticsEvent) {
        switch event {
        case .editBtcAmountTapped(let source):
            Analytics.logEvent("edit_btc_amount_tapped", parameters: ["source": source])

        case .addCurrencyButtonTapped:
            Analytics.logEvent("add_currency_button_tapped", parameters: nil)

        case .welcomeAlertGetStarted:
            Analytics.logEvent("welcome_alert_get_started", parameters: nil)

        case .welcomeAlertMaybeLater:
            Analytics.logEvent("welcome_alert_maybe_later", parameters: nil)

        case .editAmountAlertSaved:
            Analytics.logEvent("edit_amount_alert_saved", parameters: nil)

        case .currencySelectionCancelled:
            Analytics.logEvent("currency_selection_cancelled", parameters: nil)

        case .currencySelectionSaved(let selectedCount):
            Analytics.logEvent("currency_selection_saved", parameters: ["selected_count": selectedCount])

        case .currencyToggled(let currencyCode, let wasSelectedBefore):
            Analytics.logEvent("currency_toggled", parameters: [
                "currency_code": currencyCode,
                "was_selected_before": wasSelectedBefore
            ])
        }
    }
}
