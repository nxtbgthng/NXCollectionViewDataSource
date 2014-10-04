# UICollectionView Data Source

This project provides generic data source classes for `UICollectionView`. The `NXStaticCollectionViewDataSource` can be used with static content provided as an array of arrays. The `NXFetchedCollectionViewDataSource` can be used with an `NSFetchRequest` which will keep the collection view updated as the content in the database changes.


## General Usage

The data source must be initialized with the colelction view, it should manage. From this point, the control over the collection view is handed over to the data source and the methods to insert, move or delete cells must not be called manually.

### Creating a Data Source

A static data soruce just takes the collection view as argument, a fetched data source also needs the managed object context, it should use.

	// Get a Reference to the collection view.
	
	UICollectionView *collectionView = ... the collection view ...
	
	// Create the Data Source with the collection view
	// and (in case of a fetched data source) a managed obejct context.  
	
	NXFetchedCollectionViewDataSource *dataSource = [[NXFetchedCollectionViewDataSource alloc] 
	                                                    initWithCollectionView:collectionView
	                                                      managedObjectContext:self.managedObjectContext];
	                                                      

### Registering Cells and Supplementary Views

Cells and supplementary views can either be registerd with a class or a nib. The registration is done together with a prepare block. This block is called for preparation and can be used to get the item from the data source and set it as a value of the cell (or supplementary view).

	[dataSource registerClass:[MyCollectionViewCell class]    
	         withPrepareBlock:^(id view, NSIndexPath *indexPath, NXCollectionViewDataSource *dataSource) {
	         
	         MyCollectionViewCell *cell = view;
	         
	         id myItem = [dataSource itemAtIndexPath:indexPath];
	         cell.item = myItem;
	}];

Because the data source holds a strong reference to the block, care must be taken to not build a retain cycle. If possible, avoid refereing to self in those blocks.

### Loading the Content

After preparing the data source, it has to be reloaded. this initially populateds the collection view with the content and (in case of a ffetched data source) keeps it up to date with the changes in the managed object context.
	
	// The fetch request defining the content which should be shown.
	NSFetchRequest *request = ...
	
	// An optional key path to have a sectioned result.
	NSString *sectionKeyPath = ...
	
	// Perform the initial fetch and keep the data source up to date.
	[dataSource reloadWithFetchRequest:request
	                    sectionKeyPath:sectionKeyPath];

### Attribute and Relationship Sections

In addition to sections defined by a key path, the fetched data source can also group the result by attributes or relationships and returns the expected value as object of the coresponding type. This allows for example to group items by a date property of type NSDate and have an NSDate object as section item.

Using a relationship for the section allows grouping by that relatinship and also accessing this object in the supplementary view for the section header. This can for example be used to show a list of persons and section them by there relation to a group. The sectin header can than show details about that group.

    
    // Create a requet and sort the result by the group name.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"group.name"
                                                               ascending:YES]];
    
    // Get the entity description for the group and relaod the data source
    // with this relationship for the sections.
    NSEntityDescription *groupEntityDescription = ... entity description for groups ...
    
    [dataSource reloadWithFetchRequest:request 
        sectionRelationshipDescription:groupRelationshipDescription];

	// The sections are now the managed objects (in this case the groups)
	// of the given relationship.
	NSManagedObject *group = [datasSource itemForSection:0];

The data soruce supports at the moment to-one relationships and numeric, booleanm string, and date attributes.

## BSD License

Copyright © 2014, nxtbgthng GmbH

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
Neither the name of nxtbgthng nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
