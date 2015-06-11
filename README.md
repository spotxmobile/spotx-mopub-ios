# spotx-mopub-ios
MoPub plugin for integrating with SpotXchange.



## Installing

There are two ways to install this plugin:


#### CocoaPods

This is the preferred way. Simply add the following to your Podfile.

```
pod 'SpotX-MoPub-Plugin'
```


#### Source Code

Download the source code and import it in your Xcode project. The project is available from our GitHub repository at [https://github.com/spotxmobile/spotx-mopub-ios](https://github.com/spotxmobile/spotx-mopub-ios).

----------------

## Configuration

### SpotXchange

You'll need to apply to become a SpotX publisher if you haven't already.
You will receive a publisher channel ID and an account to log in the [SpotXchange Publisher Tools](https://publisher.spotxchange.com/)

### MoPub
  You'll need to create an account with MoPub if you haven't already. For more information on MoPub custom events, read http://mopub

You will use the custom data field to pass configuration parameters to the SpotXchange plugin. The custom data is a [JSON](http://json.org) object with the following keys:

* channel_id - Your SpotXchange  publisher channel ID
* playstore_url - URL to your app in the Google Play store.
* app_domain - Internet domain for your app's website
* iab_category - IAB category used to classify your app
* auto_init -
* prefetch -
* in\_app\_browser - If true, ad interactions will be displayed in an internal browser rather than the system default

For step by step instructions on how to specifiy parameters through the MoPub UI, read [here](https://dev.twitter.com/mopub/ad-networks).