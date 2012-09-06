//
//  pomodoro_timeAppDelegate.h
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class pomodoro_timeViewController;

@interface pomodoro_timeAppDelegate : MCMApplicationDelegate <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet pomodoro_timeViewController *viewController;

@end
