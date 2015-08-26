##Who Can Use the Plugin

To use the plugin, you need to be a SpotXchange publisher and have an active account with MoPub.

### Become a SpotXchange Publisher

If you are not already a SpotXchange publisher, click [here](http://www.spotxchange.com/publishers/apply-to-become-a-spotx-publisher/) to apply.

### Create a MoPub Account

If you don't yet have a MoPub account, click [here](https://app.mopub.com/account/register/) to sign up.


## What the Plugin Does

The plugin allows the SpotX SDK and the MoPub SDK to communicate with each other seamlessly. To use this new plugin, SpotX publishers will need to integrate the SpotX SDK and the MoPub SDK into their App.


## How to Install the Plugin

There are two ways to install this plugin:

### CocoaPods (preferred)

Simply add the following to your Podfile.

```ruby
pod 'SpotX-MoPub-Plugin'
```

### Source Code

Download the source code and import it in your Xcode project. The project is available from our [Github repository](https://github.com/spotxmobile/spotx-mopub-ios).


## Configuration

Use the custom data field to pass configuration parameters to the SpotX plugin. Additional details are available in the documentation for [MoPub Custom Events](https://dev.twitter.com/mopub/ad-networks). The custom data is a [JSON](http://json.org) object with the following required keys:

* channel\_id - Your SpotXchange publisher channel ID
* iab_category - IAB category used to classify your app
* iab_section - IAB category subsection used to classify your app
* appstore\_url - URL to your app in the Apple App store.
* app_domain - Internet domain for your app's website

In addition to the required properties, you may also include any of the following optional keys (*default value in parenthesis):

* use_https - (*false*) All network requests will be done over HTTPS
* use\_native\_browser - (*true*) If false, ad interactions will be displayed in an internal browser rather than the system default
* allow_calendar - (*false*) Allow ads to create calendar events
* allow_phone - (*false*) Allow ads to initiate a phone call
* allow_sms - (*false*) Allow ads to author an SMS message 
* allow_storage - (*false*) Allow ads to store images
* skippable - (*false*) Request ads that are skippable
* trackable - (*true*) Disable ad tracking
* params - (*undefined*) A hash of key-value strings that are passed-through in the ad request

Get step-by-step instructions on how to specify parameters through the MoPub UI in MoPUb'a [Ad Network Documentation](https://dev.twitter.com/mopub/ad-networks).