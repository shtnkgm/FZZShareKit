Pod::Spec.new do |s|

s.name         = "FZZShareKit"
s.version      = "0.0.14"
s.summary      = "共有画面をかんたんに作成"
s.homepage     = "http://shtnkgm.github.io/"
s.license      = { :type => "MIT", :file => "LICENSE.txt" }
s.author       = 'Shota Nakagami'
s.platform     = :ios, "8.0"
s.requires_arc = true
s.source       = { :git => "https://shtnkgm@bitbucket.org/shtnkgm/fzzsharekit.git", :tag => s.version }
s.source_files = "FZZShareKit/FZZ*.{h,m}", "FZZShareKit/NSString+FZZShareKitLocalized.{h,m}"
s.resources    = ["FZZShareKit/*.{xib}","FZZShareKit/*.{png}"]
s.resource_bundles = { 'FZZShareKit' => ["FZZShareKit/*.lproj"]}
s.framework  = 'Foundation', 'UIKit'
s.dependency 'SVProgressHUD'
s.dependency 'ChameleonFramework'
s.dependency 'TOCropViewController'
s.dependency 'TTOpenInAppActivity'

end