//
//  AppOpenAdsViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 10/31/24.
//

import SwiftUI

struct AppOpenAdsViewModifier: ViewModifier {
    @Binding var shouldShowAd: Bool
    @StateObject var appOpenAdsENV: AppOpenAdsENV
    @Environment(\.canShowAds) var canShowAds: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: shouldShowAd) { shouldShow in
                if shouldShow && canShowAds {
                    shouldShowAd = false
                    appOpenAdsENV.showAd()
                }
            }
            .onChange(of: appOpenAdsENV.adToDisplay) { info in
                if let ad = info?.ad, let rootVC = UIApplication.shared.getTopViewController() {
                    ad.present(fromRootViewController: rootVC)
                }
            }
    }
}

public extension View {
    func nnAppOpenAd(shouldShowAd: Binding<Bool>, adUnitId: String, delegate: AdDelegate? = nil) -> some View {
        modifier(AppOpenAdsViewModifier(shouldShowAd: shouldShowAd, appOpenAdsENV: .init(adUnitId: adUnitId, delegate: delegate ?? AppOpenDelegateAdapter())))
    }
}
