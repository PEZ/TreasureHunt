//
//  User.h
//  treasure
//
//  Created by Peter Stromberg on 2012-05-04.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface THUser : NSManagedObject

@property (nonatomic, retain) NSString * serverKey;

@end
