package com.nab.flutter.ads

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import com.nab.flutter.ads.R


class CommonNativeAd (val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context).inflate(R.layout.common_native_ad, null) as NativeAdView

        with (adView) {
            // Set the media view.
            val mediaView = findViewById<MediaView>(R.id.ad_media)
            setMediaView(mediaView)

            // Set other ad assets.
            val headlineView = findViewById<TextView>(R.id.ad_headline)
            setHeadlineView(headlineView)
            val bodyView = findViewById<TextView>(R.id.ad_body)
            setBodyView(bodyView)
            val callToActionView = findViewById<Button>(R.id.ad_call_to_action)
            setCallToActionView(callToActionView)
            val iconView = findViewById<ImageView>(R.id.ad_app_icon)
            setIconView(iconView)

            // The headline and mediaContent are guaranteed to be in every NativeAd.
            headlineView.text = nativeAd.headline
            mediaView.mediaContent = nativeAd.mediaContent

            // These assets aren't guaranteed to be in every NativeAd, so it's important to
            // check before trying to display them.
            if (nativeAd.body == null) {
                bodyView.visibility = View.INVISIBLE
            } else {
                bodyView.visibility = View.VISIBLE
                bodyView.text = nativeAd.body
            }
            if (nativeAd.callToAction == null) {
                callToActionView.visibility = View.INVISIBLE
            } else {
                callToActionView.visibility = View.VISIBLE
                callToActionView.text = nativeAd.callToAction
            }
            if (nativeAd.icon == null) {
                iconView.visibility = View.GONE
            } else {
                // attributionViewSmall.setVisibility(View.VISIBLE);
                // getAttributionViewLarge().setVisibility(View.VISIBLE);
                iconView.setImageDrawable(nativeAd.icon!!.drawable)
                iconView.visibility = View.VISIBLE
            }

            setNativeAd(nativeAd)
        }
        return adView
    }
}
