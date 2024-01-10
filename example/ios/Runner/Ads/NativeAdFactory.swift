//
//  UnifiedNativeAdFactory.swift
//  Runner
//
//  Created by Tinh Vu on 7/25/23.
//

import Foundation
import google_mobile_ads

class NativeAdFactory: FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: GADNativeAd,
        customOptions: [AnyHashable: Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView
        
        nativeAdView.layer.cornerRadius = 8
        nativeAdView.clipsToBounds = true
        nativeAdView.layer.borderWidth = 2
        nativeAdView.layer.borderColor = UIColor(named: "buttonColor")?.cgColor

        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil

        nativeAdView.callToActionView?.isUserInteractionEnabled = false

        nativeAdView.nativeAd = nativeAd

        return nativeAdView
    }

}
