Pod::Spec.new do |s|

    s.name               = "MXCheckmark"
    s.version            = "1.0.0"
    s.summary            = "MXCheckmark is an implementation of easy customizable checkbox made by mxcat."
    s.homepage           = "https://github.com/mx-cat/checkmark."
    s.license            = "MIT"
    s.author             = { "Maxim Krouk" => "maximkrouk@gmail.com" }
    s.social_media_url   = "https://twitter.com/mxcat_"

    s.platform           = :ios, "11.0"
    s.source             = { :git => "https://github.com/mx-cat/checkmark..git", :tag => s.version }

    s.source_files       = "Source/*.swift"

    s.framework          = "UIKit"
    s.swift_version      = "5.0"

end
