//
//  Task.m
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@implementation Task
@synthesize identity;
@synthesize name;
@synthesize done;

- (id)initWithName:(NSString*)newName;
{
    self = [super init];
    if (self) {
        self.name = newName;
        self.done = NO;
    }
    
    return self;
}

- (id)initWithID:(NSNumber*)newIdentity andName:(NSString*)newName andDone:(BOOL)newDone {
    self = [self initWithName:newName];
    
    if (self) {
        self.identity = newIdentity;
        self.done = newDone;
    }
    
    return self;
}

- (NSString*) description {
    return self.name;
}

- (void) dealloc {
    [name release];
    name = nil;
    
    [super dealloc];
}

@end
