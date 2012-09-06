//
//  pomodoro_timeAppDelegate.m
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "pomodoro_timeAppDelegate.h"

#import "pomodoro_timeViewController.h"

@implementation pomodoro_timeAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

+ (void)initialize {
    [super initialize];
    // Indicamos el color de la barra de estado.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
    // Se inicializan los valores por defecto de la configuración de la aplicación
    // por los definidos en Settings.bundle para así distinguir los cambios del
    // usuario. Tomado del libro, Desarrollo de aplicaciones para iPhone & iPad de Anaya Multimedia.
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *pListPath = [path stringByAppendingPathComponent:@"Settings/Settings.bundle/Root.plist"];
    
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:pListPath];
    
    NSMutableArray *prefsArray = [pList objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *regDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in prefsArray) {
        NSString *key = [dict objectForKey:@"Key"];
        if (key) {
            id value = [dict objectForKey:@"DefaultValue"];
            [regDictionary setObject:value forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:regDictionary];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#pragma mark -- MALCOM Begin
	[super application:application didFinishLaunchingWithOptions:launchOptions];
#pragma mark MALCOM End --

    // Override point for customization after application launch.
    if ([self.viewController isKindOfClass:[pomodoro_timeViewController class]]) {
        // Al iniciar la aplicación indicamos la ruta de la carpeta de Caché de la aplicación.
        NSArray* cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cachePath = [cachePaths objectAtIndex:0];
        
        ((pomodoro_timeViewController*) self.viewController).countdownStateFile = cachePath;
    }
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
#pragma mark -- MALCOM Begin
	[super applicationWillResignActive:application];
#pragma mark MALCOM End --

    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#pragma mark -- MALCOM Begin
	[super applicationDidEnterBackground:application];
#pragma mark MALCOM End --

    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    // Si entramos en segundo plano, detenemos las tareas actualmente activas y guardamos su estado.
    if ([self.viewController isKindOfClass:[pomodoro_timeViewController class]]) {
        [((pomodoro_timeViewController*) self.viewController) stopCountdownAndSaveState];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#pragma mark -- MALCOM Begin
	[super applicationWillEnterForeground:application];
#pragma mark MALCOM End --

    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#pragma mark -- MALCOM Begin
	[super applicationDidBecomeActive:application];
#pragma mark MALCOM End --

    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // Si entramos en segundo plano, detenemos las tareas actualmente activas y guardamos su estado.
    if ([self.viewController isKindOfClass:[pomodoro_timeViewController class]]) {
        [((pomodoro_timeViewController*) self.viewController) restartCountdownFromPreviousState];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#pragma mark -- MALCOM Begin
	[super applicationWillTerminate:application];
#pragma mark MALCOM End --

    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
