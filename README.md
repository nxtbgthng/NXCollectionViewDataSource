# UICollectionView Data Source

This project provides generic data source classes for `UICollectionView`s. The `NXStaticCollectionViewDataSource` can be used with static content provided as an array of arrays. The `NXFetchedCollectionViewDataSource` can be used with an `NSFetchRequest` which will keep the collectio view updated as the content in the database changes.

### Registering Cell and Supplementaty View Classes

The `UICollectionViewCell`subclass is registered together with a block, wich can be used to prepare the cell. If you call self in this block be aware of retain cycles, as the data source has a strong reference to the block.

	[dataSource registerClass:[MyCollectionViewCell class]    
	         withPrepareBlock:^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
	         
	         MyCollectionViewCell *cell = view;
	         
	         id myItem = [dataSource itemAtIndexPath:indexPath];
	         cell.item = myItem;
	}];

## Static Data Source

## Fetched Data Source
