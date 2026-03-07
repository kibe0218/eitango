import Foundation

struct DelayController {
    static func wait(seconds: Int) async throws {
        let totalWait: UInt64 = UInt64(1_000_000_000 * seconds)
        try await Task.sleep(nanoseconds: totalWait)
    }
}
