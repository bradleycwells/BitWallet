import Foundation
import UIKit
import AudioToolbox

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func triggerSuccess() {
        // Vibrate
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // 1057 is a common "tink" sound
        AudioServicesPlaySystemSound(1322)
    }
    
    func triggerLogoAnimationComplete(){
        AudioServicesPlaySystemSound(1407)
    }
    
    func playNotificationSound() {
        AudioServicesPlaySystemSound(1057)
    }
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
