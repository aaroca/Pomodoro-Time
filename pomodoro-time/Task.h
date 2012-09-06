//
//  Task.h
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject {
    NSNumber *identity;
    NSString *name;
    BOOL done;
}

@property (nonatomic, retain) NSNumber *identity;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL done;

- (id)initWithName:(NSString*)newName;
- (id)initWithID:(NSNumber*)newIdentity andName:(NSString*)newName andDone:(BOOL)newDone;

@end
