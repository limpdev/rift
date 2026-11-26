import Foundation

/// Represents the visual rendering style for spawned click ripples.
enum RippleStyle: String, CaseIterable, Identifiable {
  case ring
  case filled

  var id: String {
    rawValue
  }

  var title: String {
    switch self {
    case .ring:
      return "Ring"
    case .filled:
      return "Filled"
    }
  }

  var systemImage: String {
    switch self {
    case .ring:
      return "wave.3.down.circle"
    case .filled:
      return "wave.3.down.circle.fill"
    }
  }
}
