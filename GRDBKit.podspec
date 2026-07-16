Pod::Spec.new do |s|
    
    s.name                    = 'GRDBKit'
    s.version                 = '2.0.0'
    s.summary                 = 'Using ideas from Vapor\'s Fluent with GRDB.swift'
    s.description             = <<-DESC
                                The main object of this framework is to create some ORM
                                type helpers for using sqlite with GRDB.
                                DESC
    
    s.homepage                = 'https://github.com/hiimtmac/GRDBKit'
    s.license                 = { :type => 'MIT', :file => 'LICENSE' }
    
    s.author                  = 'hiimtmac'
    s.ios.deployment_target   = '13.0'
    s.swift_version           = '5.3'
    
    s.source                  = { :git => "https://github.com/hiimtmac/GRDBKit.git", :tag => "#{s.version}" }
    s.source_files            = "Sources/GRDBKit/**/*.{swift}"
    s.requires_arc            = true
    
    s.framework               = 'GRDB'
    s.dependency 'GRDB.swift'
    
end
