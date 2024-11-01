//
//  AppOpenDelegateAdapter.swift
//  
//
//  Created by Nikolai Nobadi on 10/31/24.
//

final class AppOpenDelegateAdapter: AdDelegate {
    func adDidRecordClick() { }
    func adDidRecordImpression() { }
    func adWillDismiss() { }
    func adFailedToPresent(error: Error) { }
}
