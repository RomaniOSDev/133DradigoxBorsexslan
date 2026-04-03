//
//  AppExternalURL.swift
//  133DradigoxBorsexslan
//

import Foundation

enum AppExternalURL {
    case privacyPolicy
    case termsOfUse

    private var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://dradigox133borsexslan.site/privacy/84"
        case .termsOfUse:
            return "https://dradigox133borsexslan.site/terms/84"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
