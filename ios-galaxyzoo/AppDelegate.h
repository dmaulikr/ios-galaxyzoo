//
//  AppDelegate.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <RestKit.h>
#import "client/ZooniverseClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) RKObjectManager *rkObjectManager;
@property (readonly, strong, nonatomic) RKManagedObjectStore *rkManagedObjectStore;

@property (readonly, strong, nonatomic) ZooniverseClient *zooniverseClient;

- (void)saveContext;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;

+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

+ (void)setLogin:(NSString *)username
          apiKey:(NSString *)apiKey;
+ (BOOL)isLoggedIn;
+ (void)clearLogin;
+ (NSString *)loginUsername;
+ (NSString *)loginApiKey;

+ (NSInteger) preferenceDownloadInAdvance;
+ (NSInteger) preferenceKeep;
+ (BOOL) preferenceOfferDiscussion;
+ (BOOL) preferenceWiFiOnly;

@end

