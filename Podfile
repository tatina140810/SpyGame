platform :ios, '15.0'
use_frameworks!

target 'SpyGame' do
  # Yandex Mobile Ads SDK.
  # When you register at https://partner.yandex.com and create ad units, swap
  # the demo IDs in SpyGame/Helpers/AdManager.swift for your own.
  pod 'YandexMobileAds'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
