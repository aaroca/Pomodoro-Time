//
//  DAOutil.m
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 06/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DAOutil.h"

@implementation DAOutil
@synthesize db;
@synthesize dbPath;

static DAOutil *instance;

- (id)init
{
    self = [super init];
    if (self) {
        // Verificamos que la base de datos esté inicializada.
        if (![self isDatabaseInitialized]) {
            // En caso de que no, se inicializa tomando la base de datos
            // modelo incluída entre los recursos de la aplicación.
            [self initializeDatabase];
        }
        
        // Accedo a la base de datos o la creo si no existe
        self.db = [FMDatabase databaseWithPath:self.dbPath];
        
        // Abro la base de datos y si no lo consigo nulifico
        // el objeto encargado de su manipulación.
        if (![self.db open]) {
            [self.db release];
            self.db = nil;
        }
    }
    
    return self;
}

+ (id)instance {
    if (instance == nil) {
        instance = [[DAOutil alloc] init];
    }

    return instance;
}

- (BOOL)isDatabaseInitialized {
    BOOL databaseInitialized = NO;
    
    // Obtenemos la ruta de la carpeta de documentos donde almacenaremos
    // la base de datos.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    // Almacenamos la ruta para utilizarla al para abrir/crear la base de datos.
    self.dbPath = [documentsPath stringByAppendingPathComponent:@"pomodoro-time.db"];
    
    // Ahora verificamos si el archivo existe o no. De esta forma comprobamos que la base de datos
    // inicial existe.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:self.dbPath]) {
        databaseInitialized = YES;
    }
    
    return databaseInitialized;
}

- (void)initializeDatabase {
    // Obtenemos la ruta donde está almacenada la base de datos inicial
    // para su inicialización.
    NSString *initialDatabasePath = [[NSBundle mainBundle] pathForResource:@"pomodoro-time" ofType:@"db"];
    
    // Copiamos la base de datos inicial a la ruta donde debería de estar.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:initialDatabasePath toPath:self.dbPath error:nil];
}

- (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray*)arguments {
    return [self.db executeUpdate:sql withArgumentsInArray:arguments];
}

- (FMResultSet*)executeQuery:(NSString*)sql withArgumentsInArray:(NSArray*)arguments {
    return [self.db executeQuery:sql withArgumentsInArray:arguments];
}

- (BOOL)beginTransaction {
    return [self.db beginTransaction];
}

- (BOOL)commit {
    return [self.db commit];
}

- (BOOL)rollback {
    return [self.db rollback];
}

- (void)dealloc {
    [self.db close]; // Cierro la base de datos.
    [self.db release];
    [self setDb:nil];
    
    [self.dbPath release];
    [self setDbPath:nil];
    
    [super dealloc];
}

@end
