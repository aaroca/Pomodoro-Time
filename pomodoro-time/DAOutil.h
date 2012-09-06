//
//  DAOutil.h
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DAOutil : NSObject {
    FMDatabase *db;
    NSString *dbPath;
}

@property (nonatomic, retain) FMDatabase *db;
@property (nonatomic, retain) NSString *dbPath;

+ (id)instance;
- (BOOL)isDatabaseInitialized;
- (void)initializeDatabase;

// Métodos para realizar operaciones contra la BD sin utilizar diréctamente
// el objeto db.
- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray*)arguments;
- (FMResultSet*)executeQuery:(NSString*)sql withArgumentsInArray:(NSArray*)arguments;
- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;

@end
