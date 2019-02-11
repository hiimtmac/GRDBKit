Pod::Spec.new do |s|
    
    s.name                    = "GRDBKit"
    s.version                 = "0.0.1"
    s.summary                 = "Using ideas from Vapor's Fluent with GRDB.swift"
    s.homepage                = "http://github.com/hiimtmac/GRDBKit"
    s.license                 = { :type => "MIT", :file => "LICENSE" }
    s.author                  = "Taylor McIntyre"
    s.social_media_url        = "http://twitter.com/hiimtmac"
    s.platform                = :ios
    s.source                  = {
        :git => "https://github.com/hiimtmac/GRDBKit.git",
        :tag => s.version
    }
    s.source_files            = "GRDBKit/**/*.swift"
    s.requires_arc            = true
    s.ios.deployment_target   = "11.0"
    s.swift_version           = "4.2"
    s.framework               = "GRDB"
    s.dependency "GRDB.swift"

end
