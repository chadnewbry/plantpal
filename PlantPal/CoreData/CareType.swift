import Foundation

enum CareType: String, CaseIterable, Identifiable {
    case water
    case fertilize
    case repot
    case prune
    case rotate
    case mist
    case light  // light adjustment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .water: return "Water"
        case .fertilize: return "Fertilize"
        case .repot: return "Repot"
        case .prune: return "Prune"
        case .rotate: return "Rotate"
        case .mist: return "Mist"
        case .light: return "Light Adjustment"
        }
    }

    var systemImage: String {
        switch self {
        case .water: return "drop.fill"
        case .fertilize: return "leaf.arrow.circlepath"
        case .repot: return "square.and.arrow.down"
        case .prune: return "scissors"
        case .rotate: return "arrow.triangle.2.circlepath"
        case .mist: return "humidity.fill"
        case .light: return "sun.max.fill"
        }
    }
}
