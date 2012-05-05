//
//  THUser+FetchFirstOnly.h
//  treasure
//
//  Created by Peter Stromberg on 2012-05-05.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "THUser.h"

@interface THUser (FetchFirstOnly)

+ (NSEntityDescription *)entityInManagedObjectContext:(NSManagedObjectContext *)context;
+ (THUser *)firstInManagedObjectContext:(NSManagedObjectContext *)context;

@end
