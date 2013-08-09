//
//  InitialViewController.m
//  CoreDataTest
//
//  Created by Matthew Krueger on 8/5/13.
//  Copyright (c) 2013 Arthrex. All rights reserved.
//

#import "InitialViewController.h"
#import "DatabaseManager.h"
#import "Country.h"
#import "AssetType.h"
#import "Asset.h"
#import "TeamViewController.h"

@interface InitialViewController ()

@property (nonatomic) BOOL assetClassificationsImported;
@property (nonatomic) BOOL assetsImported;
@property (nonatomic) BOOL assetTypeAssetsImported;
@property (nonatomic) BOOL assetTypesImported;
@property (nonatomic) BOOL closuresImported;
@property (nonatomic) BOOL countriesImported;
@property (nonatomic) BOOL localesImported;
@property (nonatomic) BOOL taxasImported;
@property (nonatomic) BOOL taxonGroupsImported;

@property (nonatomic) BOOL assetClassificationsBeingLinked;
@property (nonatomic) BOOL assetsBeingLinked;
@property (nonatomic) BOOL assetTypeAssetsBeingLinked;
@property (nonatomic) BOOL assetTypesBeingLinked;
@property (nonatomic) BOOL closuresBeingLinked;
@property (nonatomic) BOOL taxasBeingLinked;

@property (nonatomic) BOOL linkTaxasCompleted;
@property (nonatomic) BOOL linkAssetsCompleted;
@property (nonatomic) BOOL linkAssetTypeAssetsCompleted;

@property (nonatomic, strong) NSMutableArray *linkSelectors;
@property (nonatomic, strong) NSDate *start;

@end

@implementation InitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.linkSelectors = [NSMutableArray arrayWithObjects:@"linkTaxas", @"linkAssets", @"linkAssetTypeAssets", nil];
    }
    return self;
}

- (DatabaseManager *)databaseManager
{
    static DatabaseManager *_databaseManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _databaseManager = [[DatabaseManager alloc] init];
    });
    return _databaseManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)download:(id)sender
{
    [[self databaseManager] downloadDatabaseWithSuccess:^{
        NSLog(@"complete");
    } andFailure:^(NSError *error) {
        NSLog(@"failed");
    }];
}

- (IBAction)import:(id)sender
{
//[[self databaseManager] deleteAndRecreateStore];
    
    self.start = [NSDate date];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importAssetClassifications];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importAssets];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importAssetTypes];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importAssetTypesAssets];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importClosures];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importCountries];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importLocales];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importTaxas];
//	});
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//		[self importTaxonGroups];
//	});
    
//    [[self databaseManager] insertContext];
    
    [self performSelectorInBackground:@selector(importAssetClassifications) withObject:nil];
    [self performSelectorInBackground:@selector(importAssets) withObject:nil];
    [self performSelectorInBackground:@selector(importAssetTypes) withObject:nil];
    [self performSelectorInBackground:@selector(importAssetTypesAssets) withObject:nil];
    [self performSelectorInBackground:@selector(importClosures) withObject:nil];
    [self performSelectorInBackground:@selector(importCountries) withObject:nil];
    [self performSelectorInBackground:@selector(importLocales) withObject:nil];
    [self performSelectorInBackground:@selector(importTaxas) withObject:nil];
    [self performSelectorInBackground:@selector(importTaxonGroups) withObject:nil];
    
//    [[self databaseManager] addAllTaxa];
}

- (void)importAssetClassifications
{
    [[self databaseManager] importAssetClassificationsToCoreDataWithCompletion:^(BOOL complete) {
        self.assetClassificationsImported = complete;
        NSLog(@"importAssetClassifications");
        [self areAllImported];
    }];
}

- (void)importAssets
{
    [[self databaseManager] importAssetsToCoreDataWithCompletion:^(BOOL complete) {
        self.assetsImported = complete;
        NSLog(@"importAssets");
        [self areAllImported];
    }];
}

- (void)importAssetTypesAssets
{
    [[self databaseManager] importAssetTypeAssetsToCoreDataWithCompletion:^(BOOL complete) {
        self.assetTypeAssetsImported = complete;
        NSLog(@"importAssetTypesAssets");
        [self areAllImported];
    }];
}

- (void)importAssetTypes
{
    [[self databaseManager] importAssetTypesToCoreDataWithCompletion:^(BOOL complete) {
        self.assetTypesImported = complete;
        NSLog(@"importAssetTypes");
        [self areAllImported];
    }];
}

- (void)importClosures
{
    [[self databaseManager] importClosuresToCoreDataWithCompletion:^(BOOL complete) {
        self.closuresImported = complete;
        NSLog(@"importClosures");
        [self areAllImported];
    }];
}

- (void)importCountries
{
    [[self databaseManager] importCountriesToCoreDataWithCompletion:^(BOOL complete) {
        self.countriesImported = complete;
        NSLog(@"importCountries");
        [self areAllImported];
    }];
}

- (void)importLocales
{
    [[self databaseManager] importLocalesToCoreDataWithCompletion:^(BOOL complete) {
        self.localesImported = complete;
        NSLog(@"importLocales");
        [self areAllImported];
    }];
}

- (void)importTaxas
{
    [[self databaseManager] importTaxaToCoreDataWithCompletion:^(BOOL complete) {
        self.taxasImported = complete;
        NSLog(@"importTaxas");
        [self areAllImported];
    }];
}

- (void)importTaxonGroups
{
    [[self databaseManager] importTaxonGroupsToCoreDataWithCompletion:^(BOOL complete) {
        self.taxonGroupsImported = complete;
        NSLog(@"importTaxonGroups");
        [self areAllImported];
    }];
}

- (void)linkTaxas
{
    NSLog(@"Taxas Link Start");

   

    [[self databaseManager] linkTaxasWithCompletion:^(BOOL complete) {
        self.linkTaxasCompleted = YES;
        self.assetClassificationsBeingLinked = NO;
        self.taxasBeingLinked = NO;
        self.closuresImported = NO;
        NSLog(@"Taxas Linked");
        [self areAllImported];
    }];
}

- (void)linkAssets
{
    
    NSLog(@"Assets Link Start");


    [[self databaseManager] linkAssetsWithCompletion:^(BOOL complete) {
        self.linkAssetsCompleted = YES;
        self.assetClassificationsBeingLinked = NO;
        self.assetTypeAssetsBeingLinked = NO;
        self.assetsBeingLinked = NO;
        NSLog(@"Assets Linked");
        [self areAllImported];
    }];
}

- (void)linkAssetTypeAssets
{
    NSLog(@"Asset Type Assets  Link Start");
    
    [[self databaseManager] linkAssetTypeAssetsWithCompletion:^(BOOL complete) {
        self.linkAssetTypeAssetsCompleted = YES;
        self.assetTypesBeingLinked = NO;
        self.assetTypeAssetsBeingLinked = NO;
        NSLog(@"Asset Type Assets Linked");
        [self areAllImported];
    }];
}

- (void)areAllImported
{
    if (self.closuresImported &&
        self.taxasImported &&
        self.assetClassificationsImported &&
        !self.closuresBeingLinked &&
        !self.taxasBeingLinked &&
        !self.assetClassificationsBeingLinked &&
        [self.linkSelectors indexOfObject:@"linkTaxas"] != NSNotFound) {
        
        [self.linkSelectors removeObjectAtIndex:[self.linkSelectors indexOfObject:@"linkTaxas"]];

        self.assetClassificationsBeingLinked = YES;
        self.taxasBeingLinked = YES;
        self.closuresBeingLinked = YES;
        [self performSelectorInBackground:@selector(linkTaxas) withObject:nil];
    }
    
    if (self.assetClassificationsImported &&
        self.assetsImported &&
        self.assetTypeAssetsImported &&
        !self.assetClassificationsBeingLinked &&
        !self.assetsBeingLinked &&
        !self.assetTypeAssetsBeingLinked &&
        [self.linkSelectors indexOfObject:@"linkAssets"] != NSNotFound) {
        
        [self.linkSelectors removeObjectAtIndex:[self.linkSelectors indexOfObject:@"linkAssets"]];
        
        self.assetClassificationsBeingLinked = YES;
        self.assetTypeAssetsBeingLinked = YES;
        self.assetsBeingLinked = YES;
        [self performSelectorInBackground:@selector(linkAssets) withObject:nil];
    }
    
    if (self.assetTypeAssetsImported &&
        self.assetTypesImported &&
        !self.assetTypeAssetsBeingLinked &&
        !self.assetTypesBeingLinked &&
        [self.linkSelectors indexOfObject:@"linkAssetTypeAssets"] != NSNotFound) {
        
        [self.linkSelectors removeObjectAtIndex:[self.linkSelectors indexOfObject:@"linkAssetTypeAssets"]];
        
        self.assetTypesBeingLinked = YES;
        self.assetTypeAssetsBeingLinked = YES;
        [self performSelectorInBackground:@selector(linkAssetTypeAssets) withObject:nil];
    }

    if (self.assetClassificationsImported &&
        self.assetsImported &&
        self.assetTypeAssetsImported &&
        self.assetTypesImported &&
        self.closuresImported &&
        self.countriesImported &&
        self.localesImported &&
        self.taxasImported &&
        self.taxonGroupsImported) {
        NSLog(@"Import Time: %f", [self.start timeIntervalSinceNow]);
    }
}


- (IBAction)read:(id)sender
{
//    [[self databaseManager] linkAssetClassificationsToAssets];
//    [[self databaseManager] linkAssetClassificationsToTaxas];
//    [[self databaseManager] linkAssetTypeAssetsToAssets];
//    [[self databaseManager] linkAssetTypeAssetsToAssetTypes];
//    [[self databaseManager] linkClosureAncestors];
//    [[self databaseManager] linkClosureDescendants];
}

- (IBAction)teams:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]];
    TeamViewController *teamViewController = [storyboard instantiateViewControllerWithIdentifier:@"TeamViewController"];
    [self.navigationController pushViewController:teamViewController animated:YES];
}
@end
