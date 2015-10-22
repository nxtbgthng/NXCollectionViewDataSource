Pod::Spec.new do |s|
    s.name              = "NXCollectionViewDataSource"
    s.version           = "1.2.2"
    s.summary           = "Generic data source for UICollectionView using either static data of a NSFetchRequest."
    s.homepage          = "https://github.com/nxtbgthng/NXCollectionViewDataSource"
    s.license           = { :type => 'BSD', :file => 'LICENSE.md' }
    s.author            = { "Tobias Kräntzer" => "tobias@nxtbgthng.com",
                            "Andreas Goese" => "andreas@evenly.io",
                            "Thomas Kollbach" => "toto@evenly.io" }
    s.social_media_url  = 'https://twitter.com/evenly_io'
    s.ios.deployment_target = '6.0'
    s.tvos.deployment_target = '9.0'
    s.source            = { :git => "https://github.com/nxtbgthng/NXCollectionViewDataSource.git", :tag => "#{s.version}" }
    s.source_files      = 'NXCollectionViewDataSource/NXCollectionViewDataSource/*.{h,m}'
    s.framework         = 'CoreData'
    s.requires_arc      = true
end
