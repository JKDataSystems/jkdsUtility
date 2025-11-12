//
//  StoreVersion.swift
//  jkdsUtility
//
//  Created by 서창열 on 11/12/25.
//

import Foundation
import SwiftUI

/**
    앱스토어에 출시된 버전을 검색합니다.
 */
struct StoreVersion {
    /// Fetch the current App Store version using async/await.
    /// - Parameter appID: The numeric App Store app identifier.
    /// - Returns: The version string if found, otherwise `nil`.
    static func fetchAppVersion(appID: String) async -> String? {
        let urlString = "https://itunes.apple.com/lookup?id=\(appID)"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let results = json["results"] as? [[String: Any]],
               let appInfo = results.first,
               let appVersion = appInfo["version"] as? String {
                return appVersion
            } else {
                return nil
            }
        } catch {
            print("Error fetching/parsing app info: \(error.localizedDescription)")
            return nil
        }
    }

    /// Convenience wrapper to support a completion-handler style API.
    /// This function intentionally avoids `@Sendable` to prevent capturing a non-Sendable completion in a concurrent context.
    static func fetchAppVersion(appID: String, completion: @escaping @Sendable (String?) -> Void) {
        Task { // Hop to an async context safely; Task's closure is @Sendable
            let version = await fetchAppVersion(appID: appID)
            await MainActor.run {
                completion(version)
            }
        }
    }
}


#Preview {
    VStack {
        Button {
            StoreVersion.fetchAppVersion(appID: "1543840915") { version in
                print(version ?? "없음")
            }
        } label : {
            Text("getVersion")
        }
    }
}
