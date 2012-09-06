//
//  TaskDAO.m
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskDAO.h"

@implementation TaskDAO
@synthesize daoutil;

- (id)init
{
    self = [super init];
    if (self) {
        self.daoutil = [DAOutil instance];
    }
    
    return self;
}

- (NSString*)addTask:(Task*)task {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"INSERT INTO tasks (name) VALUES (?)" withArgumentsInArray:[NSArray arrayWithObjects:task.name, nil]];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
     
    return errorMessage;
}

- (NSString*)addTaskWithID:(Task*)task {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"INSERT INTO tasks (id, name, done) VALUES (?,?,?)" withArgumentsInArray:[NSArray arrayWithObjects:task.identity, task.name, [NSNumber numberWithBool:task.done], nil]];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
    
    return errorMessage;
}

- (NSString*)removeTask:(Task*)task {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"DELETE FROM tasks WHERE id == ?" withArgumentsInArray:[NSArray arrayWithObjects: task.identity, nil]];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
    
    return errorMessage;
}

- (NSString*)updateTask:(Task*)task {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"UPDATE tasks SET id = ?, name = ?, done = ? WHERE id = ?" withArgumentsInArray:[NSArray arrayWithObjects:task.identity, task.name, [NSNumber numberWithBool:task.done], task.identity, nil]];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
    
    return errorMessage;
}

- (NSString*)updateTask:(Task*)task withID:(NSNumber*)id {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"UPDATE tasks SET id = ?, name = ?, done = ? WHERE id = ?" withArgumentsInArray:[NSArray arrayWithObjects:task.identity, task.name, [NSNumber numberWithBool:task.done], id, nil]];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
    
    return errorMessage;
}

- (NSString*)moveTask:(Task*)task toPositionOfTask:(Task*)otherTask {
    NSString* errorMessage = nil;
    
    // Almacenamos la posición inicial de cada tarea para intercambiarlas.
    NSNumber *taskID = task.identity;
    NSNumber *otherTaskID = otherTask.identity;
    
    // Lo realizamos todo en una transacción para evitar daños en los datos 
    // en caso de no realizarse por completo la operación.
    [self.daoutil beginTransaction];
    
    // Eliminamos la tarea final de la BD pero la conservamos en memoria.
    errorMessage = [self removeTask:otherTask];
    
    if (errorMessage == nil) {
        // Si no hay errores, actualizamos la ID de la tarea inicial por la final (recien borrada).
        task.identity = otherTaskID;
        errorMessage = [self updateTask:task withID:taskID];
        
        if (errorMessage == nil) {
            // Si no hay errores, vuelvo a insertar la tarea final (borrada) pero con la ID de la tarea inicial.
            otherTask.identity = taskID;
            errorMessage = [self addTaskWithID:otherTask];
        } else {
            [self.daoutil rollback];
        }
    } else {
        [self.daoutil rollback];
    }
    
    if (errorMessage == nil) {
        [self.daoutil commit];
    }
    
    return errorMessage;
}

- (NSMutableArray*)listIncompleteTasks {
    NSMutableArray *incompleteTasks = nil;
    
    FMResultSet *result = [self.daoutil executeQuery:@"SELECT * FROM tasks WHERE done == 0" withArgumentsInArray:nil];
    
    while ([result next]) {
        if (incompleteTasks == nil) {
            incompleteTasks = [[[NSMutableArray alloc] init] autorelease];
        }
        
        NSNumber *identify = [NSNumber numberWithInt:[result intForColumn:@"id"]];
        NSString *name = [result stringForColumn:@"name"];
        BOOL done = [result boolForColumn:@"done"];
        
        Task* tempTask = [[Task alloc] initWithID:identify andName:name andDone:done];
        [incompleteTasks addObject:tempTask];
        [tempTask release];
    }
    
    return incompleteTasks;
}

- (NSMutableArray*)listIncompleteTasksWithName:(NSString*)taskName {
    NSMutableArray *incompleteTasks = nil;

    FMResultSet *result = [self.daoutil executeQuery:@"SELECT * FROM tasks WHERE done == 0 AND name LIKE ?" withArgumentsInArray:[NSArray arrayWithObject:[NSString stringWithFormat:@"%%%@%%", taskName]]];
    
    while ([result next]) {
        if (incompleteTasks == nil) {
            incompleteTasks = [[[NSMutableArray alloc] init] autorelease];
        }
        
        NSNumber *identify = [NSNumber numberWithInt:[result intForColumn:@"id"]];
        NSString *name = [result stringForColumn:@"name"];
        BOOL done = [result boolForColumn:@"done"];
        
        Task* tempTask = [[Task alloc] initWithID:identify andName:name andDone:done];
        [incompleteTasks addObject:tempTask];
        [tempTask release];
    }
    
    return incompleteTasks;
}

- (NSMutableArray*)listCompletedTasks {
    NSMutableArray *completeTasks = nil;
    
    FMResultSet *result = [self.daoutil executeQuery:@"SELECT * FROM tasks WHERE done == 1" withArgumentsInArray:nil];
    
    while ([result next]) {
        if (completeTasks == nil) {
            completeTasks = [[[NSMutableArray alloc] init] autorelease];
        }
        
        NSNumber *identify = [NSNumber numberWithInt:[result intForColumn:@"id"]];
        NSString *name = [result stringForColumn:@"name"];
        BOOL done = [result boolForColumn:@"done"];
        
        Task* tempTask = [[Task alloc] initWithID:identify andName:name andDone:done];
        [completeTasks addObject:tempTask];
        [tempTask release];
    }
    
    return completeTasks;
}

- (NSMutableArray*)listCompletedTasksWithName:(NSString*)taskName {
    NSMutableArray *completeTasks = nil;
    
    FMResultSet *result = [self.daoutil executeQuery:@"SELECT * FROM tasks WHERE done == 1 AND name LIKE ?" withArgumentsInArray:[NSArray arrayWithObject:[NSString stringWithFormat:@"%%%@%%", taskName]]];
    
    while ([result next]) {
        if (completeTasks == nil) {
            completeTasks = [[[NSMutableArray alloc] init] autorelease];
        }
        
        NSNumber *identify = [NSNumber numberWithInt:[result intForColumn:@"id"]];
        NSString *name = [result stringForColumn:@"name"];
        BOOL done = [result boolForColumn:@"done"];
        
        Task* tempTask = [[Task alloc] initWithID:identify andName:name andDone:done];
        [completeTasks addObject:tempTask];
        [tempTask release];
    }
    
    return completeTasks;
}

- (NSString*)removeAllTasks {
    NSString* errorMessage = nil;
    
    BOOL done = [self.daoutil executeUpdate:@"DELETE FROM tasks" withArgumentsInArray:nil];
    
    if (!done) {
        errorMessage = [self.daoutil.db lastErrorMessage];
    }
    
    return errorMessage;
}

@end
