//
//  CoreDataTest.h
//  CoreDataTest
//
//  Created by Matthew Krueger on 8/5/13.
//  Copyright (c) 2013 Arthrex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Taxa;

@interface CoreDataTest : NSManagedObject

@property (nonatomic, retain) NSString * ancestor;
@property (nonatomic, retain) NSString * descendant;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) Taxa *closureancestor;
@property (nonatomic, retain) Taxa *closuredescendant;

@end
