//
//  TaskDAO.h
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOutil.h"
#import "Task.h"

@interface TaskDAO : NSObject {
    DAOutil *daoutil;
}

@property (nonatomic, assign) DAOutil *daoutil;

// Operaciones contra la BD que devuelven en su mayoría o nil en caso de 
// haberse realizado con éxito o una cadena con un mensaje de error 
// para mostrar.
- (NSString*)addTask:(Task*)task;
- (NSString*)addTaskWithID:(Task*)task;
- (NSString*)removeTask:(Task*)task;
- (NSString*)updateTask:(Task*)task;
- (NSString*)updateTask:(Task*)task withID:(NSNumber*)id;
- (NSString*)moveTask:(Task*)task toPositionOfTask:(Task*)otherTask;
- (NSMutableArray*)listIncompleteTasks;
- (NSMutableArray*)listIncompleteTasksWithName:(NSString*)taskName;
- (NSMutableArray*)listCompletedTasks;
- (NSMutableArray*)listCompletedTasksWithName:(NSString*)taskName;
- (NSString*)removeAllTasks;

@end
