//
//  DatabaseManager.h
//  ArthrexKit
//
//  Created by Matthew Krueger on 7/26/13.
//  Copyright (c) 2013 Arthrex. All rights reserved.
//

#import "AKFileDownloadManager.h"

extern NSString *const kAPPDB;

@interface DatabaseManager : AKFileDownloadManager

- (void)downloadDatabaseWithSuccess:(void (^)(void))success andFailure:(void (^)(NSError *error))failure;

- (void)importAllDataToCoreDataWithCompletion:(void (^)(BOOL complete))completion;

- (void)importCountriesToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importAssetTypesToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importAssetsToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importClosuresToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importTaxaToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importAssetClassificationsToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importAssetTypeAssetsToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importLocalesToCoreDataWithCompletion:(void (^)(BOOL complete))completion;
- (void)importTaxonGroupsToCoreDataWithCompletion:(void (^)(BOOL complete))completion;

- (void)linkAssetsWithCompletion:(void (^)(BOOL complete))completion;
- (void)linkTaxasWithCompletion:(void (^)(BOOL complete))completion;
- (void)linkAssetTypeAssetsWithCompletion:(void (^)(BOOL complete))completion;

- (NSArray *)teams;

- (void)deleteAndRecreateStore;

- (void)checkAssetPresenters;

- (NSManagedObjectContext *)insertContext;

@end