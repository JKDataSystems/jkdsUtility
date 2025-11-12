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
public struct StoreVersion {
  
    
    /// Fetch the current App Store version using async/await.
    /// - Parameter appID: The numeric App Store app identifier.
    /// - Returns: The version string if found, otherwise `nil`.
    public static func fetchAppVersion(appID: String) async -> String? {
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
    public static func fetchAppVersion(appID: String, completion: @escaping @Sendable (String?) -> Void) {
        Task { // Hop to an async context safely; Task's closure is @Sendable
            let version = await fetchAppVersion(appID: appID)
            await MainActor.run {
                completion(version)
            }
        }
    }
    
    public enum VersionDifference {
        case majorHigherInStore
        case minorHigherInStore
        case patchHigherInStore
        case majorHigherInCurrent
        case minorHigherInCurrent
        case patchHigherInCurrent
        case equal
    }
    
    private static func compareVersions(storeVersion: String, currentVersion: String) -> VersionDifference {
        let storeComponents = storeVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }

        let maxCount = max(storeComponents.count, currentComponents.count)

        for i in 0..<maxCount {
            let storeValue = i < storeComponents.count ? storeComponents[i] : 0
            let currentValue = i < currentComponents.count ? currentComponents[i] : 0

            if storeValue > currentValue {
                switch i {
                case 0: return .majorHigherInStore
                case 1: return .minorHigherInStore
                case 2: return .patchHigherInStore
                default: return .patchHigherInStore
                }
            } else if storeValue < currentValue {
                switch i {
                case 0: return .majorHigherInCurrent
                case 1: return .minorHigherInCurrent
                case 2: return .patchHigherInCurrent
                default: return .patchHigherInCurrent
                }
            }
        }

        return .equal
    }

    /** 현제 버전과 스토어 버전 비교 */
    public static func compareAppVersion(appId:String, bundleVersion:String, complete:@escaping @Sendable (StoreVersion.VersionDifference?)->Void) {
        Task {
            let appVersion = await StoreVersion.fetchAppVersion(appID: appId)
            let result: StoreVersion.VersionDifference?
            if let version = appVersion {
                result = StoreVersion.compareVersions(storeVersion: version, currentVersion: bundleVersion)
            } else {
                result = nil
            }
            await MainActor.run {
                complete(result)
            }
        }
    }
    
    /** 현제 버전과 스토어 버전 비교 */
    public static func compareAppVersion(appId:String, bundleVersion:String) async -> StoreVersion.VersionDifference? {
        let appVersion = await StoreVersion.fetchAppVersion(appID: appId)
        let result: StoreVersion.VersionDifference?
        if let version = appVersion {
            result = StoreVersion.compareVersions(storeVersion: version, currentVersion: bundleVersion)
        } else {
            result = nil
        }
        return result
    }
}



#Preview {
    VStack {
        Button {
            StoreVersion.fetchAppVersion(appID: "1543840915") { version in
                print(version ?? "없음")
            }
  
            StoreVersion.compareAppVersion(appId: "1543840915", bundleVersion: "1.18.2") { result in
                print(result ?? "?")
            }
            
        } label : {
            Text("getVersion")
        }
    }
}

