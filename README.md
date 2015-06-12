##Who Can Use the Plugin

To use the plugin, you need to be a SpotXchange publisher and have an active account with MoPub.

### Become a SpotXchange Publisher

If you are not already a SpotXchange publisher, click [here](http://www.spotxchange.com/publishers/apply-to-become-a-spotx-publisher/) to apply.

### Create a MoPub Account

If you don't yet have a MoPub account, click [here](https://app.mopub.com/account/register/) to sign up.


## What the Plugin Does

The plugin allows the SpotX SDK and the MoPub SDK to communitate with each other seamlessly. To Use this new plugin, SpotX publishers will need to integrate the SpotX SDK and the MoPub SDK into their App.


## How to Install the Plugin

There are two ways to install this plugin:

### CocoaPods (preferred)

Simply add the following to your Podfile.

```ruby
pod 'SpotX-MoPub-Plugin'
```

### Source Code

Download the source code and import it in your Xcode project. The project is available from our GitHub repository [here](https://github.com/spotxmobile/spotx-mopub-ios).


## Configuration

You will use the custom data field to pass configuration parameters to the SpotX plugin. Get more information on MoPub custom events [here](https://dev.twitter.com/mopub/ad-networks). The custom data is a [JSON](http://json.org) object with the following keys:

* channel_id - Your SpotXchange  publisher channel ID
* appstore_url - URL to your app in the Apple App store.
* app_domain - Internet domain for your app's website
* iab_category - IAB category used to classify your app
* in\_app\_browser - If true, ad interactions will be displayed in an internal browser rather than the system default

For step by step instructions on how to specifiy parameters through the MoPub UI, read [here](https://dev.twitter.com/mopub/ad-networks).