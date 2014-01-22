Pod::Spec.new do |s|

  s.name         = "NXCollectionViewDataSource"
  s.version      = "1.0.3"
  s.summary      = "Generic data source for UICollectionView using either static data of a NSFetchRequest."
  s.homepage     = "https://code.nxtbgthng.com/libraries/nxcollectionviewdatasource"
  s.license      = 'Copyright (c) 2014 nxtbgthng GmbH. All rights reserved.'
  s.author       = { "Tobias Kräntzer" => "tobias@nxtbgthng.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "ssh://git@code.nxtbgthng.com:2223/libraries/nxcollectionviewdatasource.git", :tag => "#{s.version}" }
  s.source_files  = 'NXCollectionViewDataSource/NXCollectionViewDataSource/*.{h,m}'
  s.framework  = 'CoreData'
  s.requires_arc = true

end
