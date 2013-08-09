//
//  DatabaseManager.m
//  ArthrexKit
//
//  Created by Matthew Krueger on 7/26/13.
//  Copyright (c) 2013 Arthrex. All rights reserved.
//

#import "DatabaseManager.h"
#import "AssetManager.h"
#import "AKAsset.h"
#import "AKAPIFileClient.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

#import "Country.h"
#import "AssetType.h"
#import "Asset.h"
#import "Closure.h"
#import "Taxa.h"
#import "AssetClassification.h"
#import "AssetTypeAsset.h"
#import "Locale.h"
#import "TaxonGroup.h"

NSString *const kAPPDB = @"AppDb";

@implementation DatabaseManager

- (void)downloadDatabaseWithSuccess:(void (^)(void))success andFailure:(void (^)(NSError *error))failure
{
//    AssetManager *resourceManager = [[AssetManager alloc] init];
        [self setApiDatabaseName:@"9137F845867AC8904045DA08F578B977"];

    [self downloadDatabaseAtURL:@"https://arthrex-sqlite.s3.amazonaws.com/sqlite/9137F845867AC8904045DA08F578B977.zip?AWSAccessKeyId=AKIAJ6YLP7ZCZZQMU7JQ&Expires=1375911291&Signature=nVHhP8PPqKUfw0fNpHjlfqs%2Bge0%3D" withSuccess:^{
        if (success) {
            success();
        }
    } andFailure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];



//    [resourceManager fetchDatabaseNameAndURL:^(NSString *name, NSString *url) {
//        
//        // after we have the name and location of the db go get it
//        [self setApiDatabaseName:name];
//        [self downloadDatabaseAtURL:url withSuccess:^{
//                                            if (success) {
//                                                success();
//                                            }
//                                        } andFailure:^(NSError *error) {
//                                            if (failure) {
//                                                failure(error);
//                                            }
//                                        }];
//        
//    } andFailure:^(NSError *error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
}

- (NSArray *)teams
{
    NSError *error;
    NSManagedObjectContext *objectContext = [self insertContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"taxonGroupId = 'team' or id = 'arthrex'"]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"title"
                                        ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Taxa"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entity];
    
    return [objectContext executeFetchRequest:fetchRequest error:&error];
}

#pragma mark - imports

- (void)importAllDataToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self insertContext];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM countries"];
        
        while ([result next]) {
            Country *country = [NSEntityDescription insertNewObjectForEntityForName:@"Country"
                                                             inManagedObjectContext:insertContext];
            [country setId:[result stringForColumn:@"id"]];
            [country setName:[result stringForColumn:@"name"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"countries complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save countries: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assettypes"];
        
        while ([result next]) {
            AssetType *assetType = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:insertContext];
            
            [assetType setId:[result stringForColumn:@"id"]];
            [assetType setParent:[result stringForColumn:@"parent"]];
            [assetType setDesc:[result stringForColumn:@"description"]];
            [assetType setTitle:[result stringForColumn:@"title"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"asset types complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset types: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assets"];
        
        while ([result next]) {
            Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:insertContext];
            
            [asset setId:[result stringForColumn:@"id"]];
            [asset setVersion:[result stringForColumn:@"version"]];
            [asset setRenditionId:[result objectForColumnName:@"renditionid"]];
            [asset setFileSize:[NSNumber numberWithDouble:[result doubleForColumn:@"filesize"]]];
            [asset setDuration:[NSNumber numberWithInt:[result intForColumn:@"duration"]]];
            [asset setLiteratureNumber:[result stringForColumn:@"literatureNumber"]];
            [asset setBaseSixtyFourId:[result stringForColumn:@"basesixtyfourid"]];
            [asset setHashId:[result stringForColumn:@"hash"]];
            [asset setMetadataHash:[result stringForColumn:@"metadatahash"]];
            [asset setAssetFileTypeId:[result stringForColumn:@"assetfiletypeid"]];
            [asset setTitle:[result stringForColumn:@"title"]];
            [asset setLocaleId:[result stringForColumn:@"localeid"]];
            [asset setRevisionDate:[result stringForColumn:@"revisiondate"]];
            [asset setSortDate:[NSNumber numberWithInt:[result intForColumn:@"sortdate"]]];
            [asset setThumbnail128:[result stringForColumn:@"thumbnail128"]];
            [asset setUrl:[result stringForColumn:@"url"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"countries complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save assets: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM closures"];
        
        while ([result next]) {
            Closure *closure = [NSEntityDescription insertNewObjectForEntityForName:@"Closure" inManagedObjectContext:insertContext];
            
            [closure setAncestor:[result stringForColumn:@"ancestor"]];
            [closure setDescendant:[result stringForColumn:@"descendant"]];
            [closure setDistance:[NSNumber numberWithInt:[result intForColumn:@"distance"]]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"closures complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save closures: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM taxa"];
        
        while ([result next]) {
            Taxa *taxa = [NSEntityDescription insertNewObjectForEntityForName:@"Taxa" inManagedObjectContext:insertContext];
            [taxa setId:[result stringForColumn:@"id"]];
            [taxa setTitle:[result stringForColumn:@"title"]];
            [taxa setTaxonGroupId:[result stringForColumn:@"taxongroupid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"taxas complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save taxas: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assetclassifications"];
        
        while ([result next]) {
            AssetClassification *assetClassification = [NSEntityDescription insertNewObjectForEntityForName:@"AssetClassification" inManagedObjectContext:insertContext];
            [assetClassification setAssetId:[result stringForColumn:@"assetid"]];
            [assetClassification setTaxonId:[result stringForColumn:@"taxonid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"asset classifications complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset classifications: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assettypeassets"];
        
        while ([result next]) {
            AssetTypeAsset *assetTypeAsset = [NSEntityDescription insertNewObjectForEntityForName:@"AssetTypeAsset" inManagedObjectContext:insertContext];
            [assetTypeAsset setAssetId:[result stringForColumn:@"assetid"]];
            [assetTypeAsset setAssetTypeId:[result stringForColumn:@"assettypeid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"asset type assets complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset asset type assets: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM locales"];
        
        while ([result next]) {
            Locale *locale = [NSEntityDescription insertNewObjectForEntityForName:@"Locale" inManagedObjectContext:insertContext];
            [locale setId:[result stringForColumn:@"id"]];
            [locale setLabel:[result stringForColumn:@"label"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"locales complete");
            completion(YES);
        }
        else {
            NSLog(@"couldn't save locales: %@", [error localizedDescription]);
        }
    }];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM taxongroups"];
        
        while ([result next]) {
            TaxonGroup *taxonGroup = [NSEntityDescription insertNewObjectForEntityForName:@"TaxonGroup" inManagedObjectContext:insertContext];
            [taxonGroup setId:[result stringForColumn:@"id"]];
            [taxonGroup setLabel:[result stringForColumn:@"label"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            NSLog(@"countries complete");

            completion(YES);
        }
        else {
            NSLog(@"couldn't save taxon groups: %@", [error localizedDescription]);
        }
    }];
}

- (void)importCountriesToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
                    
        FMResultSet *result = [db executeQuery:@"SELECT * FROM countries"];
        
        while ([result next]) {
            Country *country = [NSEntityDescription insertNewObjectForEntityForName:@"Country"
                                                             inManagedObjectContext:insertContext];
            [country setId:[result stringForColumn:@"id"]];
            [country setName:[result stringForColumn:@"name"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save countries: %@", [error localizedDescription]);
        }
    }];
  }

- (void)importAssetTypesToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assettypes"];
        
        while ([result next]) {
            AssetType *assetType = [NSEntityDescription insertNewObjectForEntityForName:@"AssetType" inManagedObjectContext:insertContext];
            
            [assetType setId:[result stringForColumn:@"id"]];
            [assetType setParent:[result stringForColumn:@"parent"]];
            [assetType setDesc:[result stringForColumn:@"description"]];
            [assetType setTitle:[result stringForColumn:@"title"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset types: %@", [error localizedDescription]);
        }
    }];
    
}

- (void)importAssetsToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assets"];
        
        while ([result next]) {
            Asset *asset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:insertContext];
            
            [asset setId:[result stringForColumn:@"id"]];
            [asset setVersion:[result stringForColumn:@"version"]];
            [asset setRenditionId:[result objectForColumnName:@"renditionid"]];
            [asset setFileSize:[NSNumber numberWithDouble:[result doubleForColumn:@"filesize"]]];
            [asset setDuration:[NSNumber numberWithInt:[result intForColumn:@"duration"]]];
            [asset setLiteratureNumber:[result stringForColumn:@"literatureNumber"]];
            [asset setBaseSixtyFourId:[result stringForColumn:@"basesixtyfourid"]];
            [asset setHashId:[result stringForColumn:@"hash"]];
            [asset setMetadataHash:[result stringForColumn:@"metadatahash"]];
            [asset setAssetFileTypeId:[result stringForColumn:@"assetfiletypeid"]];
            [asset setTitle:[result stringForColumn:@"title"]];
            [asset setLocaleId:[result stringForColumn:@"localeid"]];
            [asset setRevisionDate:[result stringForColumn:@"revisiondate"]];
            [asset setSortDate:[NSNumber numberWithInt:[result intForColumn:@"sortdate"]]];
            [asset setThumbnail128:[result stringForColumn:@"thumbnail128"]];
            [asset setUrl:[result stringForColumn:@"url"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save assets: %@", [error localizedDescription]);
        }
    }];
}

- (void)importClosuresToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];

    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM closures"];
        
        while ([result next]) {
            Closure *closure = [NSEntityDescription insertNewObjectForEntityForName:@"Closure" inManagedObjectContext:insertContext];
            
            [closure setAncestor:[result stringForColumn:@"ancestor"]];
            [closure setDescendant:[result stringForColumn:@"descendant"]];
            [closure setDistance:[NSNumber numberWithInt:[result intForColumn:@"distance"]]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save closures: %@", [error localizedDescription]);
        }
    }];
    
}

- (void)importTaxaToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM taxa"];
        
        while ([result next]) {
            Taxa *taxa = [NSEntityDescription insertNewObjectForEntityForName:@"Taxa" inManagedObjectContext:insertContext];
            [taxa setId:[result stringForColumn:@"id"]];
            [taxa setTitle:[result stringForColumn:@"title"]];
            [taxa setTaxonGroupId:[result stringForColumn:@"taxongroupid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save taxas: %@", [error localizedDescription]);
        }
    }];
}

- (void)importAssetClassificationsToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assetclassifications"];
        
        while ([result next]) {
            AssetClassification *assetClassification = [NSEntityDescription insertNewObjectForEntityForName:@"AssetClassification" inManagedObjectContext:insertContext];
            [assetClassification setAssetId:[result stringForColumn:@"assetid"]];
            [assetClassification setTaxonId:[result stringForColumn:@"taxonid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset classifications: %@", [error localizedDescription]);
        }
    }];
}

- (void)importAssetTypeAssetsToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM assettypeassets"];
        
        while ([result next]) {
            AssetTypeAsset *assetTypeAsset = [NSEntityDescription insertNewObjectForEntityForName:@"AssetTypeAsset" inManagedObjectContext:insertContext];
            [assetTypeAsset setAssetId:[result stringForColumn:@"assetid"]];
            [assetTypeAsset setAssetTypeId:[result stringForColumn:@"assettypeid"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save asset asset type assets: %@", [error localizedDescription]);
        }
    }];
}

- (void)importLocalesToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM locales"];
        
        while ([result next]) {
            Locale *locale = [NSEntityDescription insertNewObjectForEntityForName:@"Locale" inManagedObjectContext:insertContext];
            [locale setId:[result stringForColumn:@"id"]];
            [locale setLabel:[result stringForColumn:@"label"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save locales: %@", [error localizedDescription]);
        }
    }];
}

- (void)importTaxonGroupsToCoreDataWithCompletion:(void (^)(BOOL complete))completion
{
    NSManagedObjectContext *insertContext = [self context];
    
    FMDatabaseQueue *apiDatabaseQueue = [FMDatabaseQueue databaseQueueWithPath:self.apiDatabasePath];
    
    [apiDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM taxongroups"];
        
        while ([result next]) {
            TaxonGroup *taxonGroup = [NSEntityDescription insertNewObjectForEntityForName:@"TaxonGroup" inManagedObjectContext:insertContext];
            [taxonGroup setId:[result stringForColumn:@"id"]];
            [taxonGroup setLabel:[result stringForColumn:@"label"]];
        }
        
        NSError *error;
        if ([insertContext save:&error]) {
            completion(YES);
        }
        else {
            NSLog(@"couldn't save taxon groups: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - private

- (NSDictionary *)productGroupsDictionary
{
    static NSDictionary *_productGroupsDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _productGroupsDictionary = @{@"product_category" : @"Product Category",
                                     @"product_family" : @"Product Family",
                                     @"product_group" : @"Product Group"};
    });
    return _productGroupsDictionary;
}

- (NSDictionary *)procedureGroupsDictionary
{
    static NSDictionary *_procedureGroupsDictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _procedureGroupsDictionary = @{@"diagnosis" : @"Diagnosis",
                                     @"procedure" : @"Procedure",
                                     @"surgical_technique" : @"Surgical Technique"};
    });
    return _procedureGroupsDictionary;
}

- (NSString *)groupInStringFromDictionary:(NSDictionary *)groups
{
    NSMutableString *groupIn = [[NSMutableString alloc] init];
    
    for (NSString *groupId in groups) {
        if (groupIn.length > 0) {
            [groupIn appendString:@","];
        }
        [groupIn appendString:@"'"];
        [groupIn appendString:groupId];
        [groupIn appendString:@"'"];
    }

    return groupIn;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)context
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];

    NSPersistentStoreCoordinator *coordinator = [self coordinator];
    if (coordinator != nil) {
        [context setPersistentStoreCoordinator:coordinator];
        context.undoManager = nil;
    }
    return context;
}

- (NSManagedObjectModel *)model
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataTest" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return model;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    NSPersistentStoreCoordinator *coordinator;
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataTest.sqlite"];
    
    NSError *error = nil;
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return coordinator;
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)insertContext
{
    static NSManagedObjectContext *_insertContext;
    if (_insertContext != nil) {
        _insertContext.undoManager = nil;
        return _insertContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _insertContext = [[NSManagedObjectContext alloc] init];
        [_insertContext setPersistentStoreCoordinator:coordinator];
        _insertContext.undoManager = nil;
    }
    return _insertContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    static NSManagedObjectModel *_managedObjectModel;
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataTest" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataTest.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSArray *)assetClassificationsForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"AssetClassification" inContext:context];
}

- (NSArray *)assetPresentersForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"AssetPresenter" inContext:context];
}

- (NSArray *)assetsForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Asset" inContext:context];
}

- (NSArray *)assetTypeAssetsForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"AssetTypeAsset" inContext:context];
}

- (NSArray *)assetTypesForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"AssetType" inContext:context];
}

- (NSArray *)closuresForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Closure" inContext:context];
}

- (NSArray *)countriesForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Country" inContext:context];
}

- (NSArray *)localesForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Locale" inContext:context];
}

- (NSArray *)presentersForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Presenter" inContext:context];
}

- (NSArray *)taxasForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"Taxa" inContext:context];
}

- (NSArray *)taxonGroupsForContext:(NSManagedObjectContext *)context
{
    return [self fetchEntinityForName:@"TaxonGroup" inContext:context];
}

- (NSArray *)fetchEntinityForName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    return [context executeFetchRequest:fetchRequest error:&error];
}

- (void)checkAssetPresenters
{
    NSInteger count = 0;
    NSArray *assetClassifications = [self assetClassificationsForContext:[self insertContext]];
    for (AssetClassification *assetClassification in assetClassifications) {
        if (!assetClassification.taxa) {
            count++;
        }
    }
    NSLog(@"%d", count);
}

- (void)linkAssetTypeAssetsWithCompletion:(void (^)(BOOL complete))completion
{
    NSError *error;
    NSManagedObjectContext *insertContext = [self context];
    
    NSString *predicateString = [NSString stringWithFormat:@"assetId == $ASSET_TYPE_ID"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    NSArray *assetTypes = [self assetTypesForContext:insertContext];

    for (AssetType *assetType in assetTypes) {
        NSDictionary *variables = @{ @"ASSET_TYPE_ID" : assetType.id };
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AssetTypeAsset"
                                                  inManagedObjectContext:insertContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:localPredicate];
        
        NSArray *assetTypeAssets = [insertContext executeFetchRequest:fetchRequest error:&error];
        
        for (AssetTypeAsset *assetTypeAsset in assetTypeAssets) {
            assetTypeAsset.assetType = assetType;
        }
    }
    if (![insertContext save:&error]) {
        NSLog(@"couldn't link asset type assets %@", [error localizedDescription]);
    }
    completion(YES);
}

- (void)linkAssetsWithCompletion:(void (^)(BOOL complete))completion
{
    NSError *error;
    NSManagedObjectContext *insertContext = [self context];
    
    NSString *predicateString = [NSString stringWithFormat:@"assetId == $ASSET_ID"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asset"
                                              inManagedObjectContext:insertContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"assetClassifications", @"assetTypeAssets"]];

    NSArray *assets = [insertContext executeFetchRequest:fetchRequest error:&error];

    
    entity = [NSEntityDescription entityForName:@"AssetClassification" inManagedObjectContext:insertContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"assets"]];
        
    NSArray *assetClassifications = [insertContext executeFetchRequest:fetchRequest error:&error];
    
    entity = [NSEntityDescription entityForName:@"AssetTypeAsset" inManagedObjectContext:insertContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"assets"]];
    
    NSArray *assetTypeAssets = [insertContext executeFetchRequest:fetchRequest error:&error];
    
    for (Asset *asset in assets) {
        NSDictionary *variables = @{ @"ASSET_ID" : asset.id };
        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];

        [[asset mutableSetValueForKeyPath:@"assetClassifications"] addObjectsFromArray:[assetClassifications filteredArrayUsingPredicate:localPredicate]];
        
         [[asset mutableSetValueForKeyPath:@"assetTypeAssets"] addObjectsFromArray:[assetTypeAssets filteredArrayUsingPredicate:localPredicate]];
//        NSDictionary *variables = @{ @"ASSET_ID" : asset.id };
//        NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AssetClassification"
//                                                  inManagedObjectContext:insertContext];
//        [fetchRequest setEntity:entity];
//        [fetchRequest setPredicate:localPredicate];
//        
//        NSArray *assetClassifications = [insertContext executeFetchRequest:fetchRequest error:&error];
//        
//        for (AssetClassification *assetClassification in assetClassifications) {
//            assetClassification.asset = asset;
//        }
//        
//        [fetchRequest setEntity:[NSEntityDescription entityForName:@"AssetTypeAsset"
//                                            inManagedObjectContext:insertContext]];
//        
//        NSArray *assetTypeAssets = [insertContext executeFetchRequest:fetchRequest error:&error];
//
//        for (AssetTypeAsset *assetTypeAsset in assetTypeAssets) {
//            assetTypeAsset.asset = asset;
//        }
    }
    if (![insertContext save:&error]) {
        NSLog(@"couldn't link assets: %@", [error localizedDescription]);
    }
    completion(YES);
}

- (void)linkTaxasWithCompletion:(void (^)(BOOL complete))completion
{
    NSError *error;
    NSManagedObjectContext *insertContext = [self context];
    
    NSString *taxonIdPredicateString = [NSString stringWithFormat:@"taxonId == $TAXON_ID"];
    NSPredicate *taxonIdPredicate = [NSPredicate predicateWithFormat:taxonIdPredicateString];
    
    NSString *ancestorPredicateString = [NSString stringWithFormat:@"ancestor == $ANCESTOR"];
    NSPredicate *ancestoPredicate = [NSPredicate predicateWithFormat:ancestorPredicateString];
    
    NSString *descendantPredicateString = [NSString stringWithFormat:@"descendant == $DESCENDANT"];
    NSPredicate *descendantPredicate = [NSPredicate predicateWithFormat:descendantPredicateString];
    
    NSArray *taxas = [self taxasForContext:insertContext];
        
    for (Taxa *taxa in taxas) {
        NSDictionary *taxonIdVariables = @{ @"TAXON_ID" : taxa.id };
        NSPredicate *localTaxonIdPredicate = [taxonIdPredicate predicateWithSubstitutionVariables:taxonIdVariables];
        
        NSDictionary *ancestorVariables = @{ @"ANCESTOR" : taxa.id };
        NSPredicate *localAncestorPredicate = [ancestoPredicate predicateWithSubstitutionVariables:ancestorVariables];

        NSDictionary *descendantIdVariables = @{ @"DESCENDANT" : taxa.id };
        NSPredicate *localDescendantPredicate = [descendantPredicate predicateWithSubstitutionVariables:descendantIdVariables];

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AssetClassification"
                                                  inManagedObjectContext:insertContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:localTaxonIdPredicate];
        
        NSArray *assetClassifications = [insertContext executeFetchRequest:fetchRequest error:&error];
        
        for (AssetClassification *assetClassification in assetClassifications) {
            assetClassification.taxa = taxa;
        }
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Closure"
                                            inManagedObjectContext:insertContext]];
        [fetchRequest setPredicate:localAncestorPredicate];

        NSArray *closures = [insertContext executeFetchRequest:fetchRequest error:&error];
        
        for (Closure *closure in closures) {
            closure.taxaAncestor = taxa;
        }
        
        [fetchRequest setPredicate:localDescendantPredicate];
        
        closures = [insertContext executeFetchRequest:fetchRequest error:&error];
        
        for (Closure *closure in closures) {
            closure.taxaDescendant = taxa;
        }        
    }
    if (![insertContext save:&error]) {
        NSLog(@"couldn't link taxas: %@", [error localizedDescription]);
    }
    completion(YES);
}

-(void)deleteAndRecreateStore
{
    NSPersistentStore * store = [[self.persistentStoreCoordinator persistentStores] lastObject];
    NSError * error;
    [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtURL:[store URL] error:&error];
    [self insertContext];
}



@end