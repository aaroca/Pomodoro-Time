//
//  pomodoro_timeViewController.h
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OCPromptView.h"
#import "TaskDAO.h"
#import "Constants.h"

@interface pomodoro_timeViewController : MCMViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchBarDelegate> {
    UITableView *taskListTable;
    UIAlertView *commitDeleteAlertView;
    UIImageView *playImage;
    OCPromptView *renameTaskAlertView;
    OCPromptView *createTaskAlertView;
    UIAlertView *startTaskAlertView;
    UIAlertView *confirmTaskDoneAlertView;
    UIAlertView *continueTaskAlertView;
    NSMutableArray *incompleteTasks;
    NSMutableArray *completedTasks;
    TaskDAO *taskDAO;
    BOOL countdown;
    NSInteger countdownMinutes;
    NSInteger countdownSeconds;
    NSString *countdownStateFile;
    NSInteger selectedTask;
    NSTimer *countdownTimer;
    AVAudioPlayer *audioPlayer;
}

@property (nonatomic, retain) IBOutlet UITableView *taskListTable;
@property (nonatomic, retain) IBOutlet UIImageView *playImage;
@property (retain, nonatomic) IBOutlet UILabel *countdownLabel;
@property (nonatomic, retain) UIAlertView *commitDeleteAlertView;
@property (nonatomic, retain) OCPromptView *renameTaskAlertView;
@property (nonatomic, retain) OCPromptView *createTaskAlertView;
@property (nonatomic, retain) UIAlertView *startTaskAlertView;
@property (nonatomic, retain) UIAlertView *confirmTaskDoneAlertView;
@property (nonatomic, retain) UIAlertView *continueTaskAlertView;
@property (nonatomic, retain) NSMutableArray *incompleteTasks;
@property (nonatomic, retain) NSMutableArray *completedTasks;
@property (nonatomic, retain) TaskDAO *taskDAO;
@property (nonatomic) BOOL countdown;
@property (nonatomic) NSInteger countdownMinutes;
@property (nonatomic) NSInteger countdownSeconds;
@property (nonatomic, retain) NSString *countdownStateFile;
@property (nonatomic) NSInteger selectedTask;
@property (nonatomic, retain) NSTimer *countdownTimer;
@property (retain, nonatomic) IBOutlet UISearchBar *searchTaskBar;
@property (retain, nonatomic) IBOutlet UIImageView *disableTaskListImage;
@property (retain, nonatomic) AVAudioPlayer *audioPlayer;

- (IBAction)showHideTaskListEditMode:(id)sender;
- (IBAction)createNewTask:(id)sender;

// Método encargado de llevar la cuenta atrás
- (void)countdown:(NSTimer*)timer;

// Método encargado de convertir los valores de minutos y segundos de la cuenta atrás
// en una cadena del tipo mm:ss
- (NSString*)countdownToNSString;

// Verifica si el usuario quiere eliminar todas las tareas y añadir un observador
// para verificar este cambio cuando la aplicación está en segundo plano.
- (void)userWantDeleteAllTasks;

// Método para detener la cuenta atrás. Utilizado cuando la aplicación es enviada a
// segundo plano por cualquier motivo. Además almacena los datos actuales de la tarea 
// activa y la cuenta atrás para continuarlo después.
- (void)stopCountdownAndSaveState;

// Continua tareas que estuvieran incompletas en el momento de enviar la aplicación
// a segundo plano.
- (void)restartCountdownFromPreviousState;

// Método llamado para desactivar el campo de búsqueda.
- (void)deactiveSearchBar;

// Método para reproducir un sonido al terminar un pomodoro.
- (void)playSound;

// Método para detener un sonido al terminar un pomodoro.
- (void)stopSound;

@end
