//
//  pomodoro_timeViewController.m
//  pomodoro-time
//
//  Created by Álvaro Aroca Muñoz on 30/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "pomodoro_timeViewController.h"

@implementation pomodoro_timeViewController
@synthesize taskListTable;
@synthesize playImage;
@synthesize countdownLabel;
@synthesize commitDeleteAlertView;
@synthesize renameTaskAlertView;
@synthesize createTaskAlertView;
@synthesize startTaskAlertView;
@synthesize confirmTaskDoneAlertView;
@synthesize continueTaskAlertView;
@synthesize incompleteTasks;
@synthesize completedTasks;
@synthesize taskDAO;
@synthesize countdown;
@synthesize countdownMinutes;
@synthesize countdownSeconds;
@synthesize countdownStateFile;
@synthesize selectedTask;
@synthesize countdownTimer;
@synthesize searchTaskBar;
@synthesize disableTaskListImage;
@synthesize audioPlayer;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Creamos el objeto encargado de las operaciones contra la BD.
    self.taskDAO = [[TaskDAO alloc] init];
    
    // Inicializamos los alertView para su uso posterior.
    self.commitDeleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Titulo de popup de confirmacion") message:NSLocalizedString(@"DeleteConfirmation", @"Texto para la confirmacion del borrado de una tarea") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"Negacion") otherButtonTitles:NSLocalizedString(@"Yes", @"Afirmacion"), nil];
    self.renameTaskAlertView = [[OCPromptView alloc] initWithPrompt:NSLocalizedString(@"RenameTask", @"Titulo popup para renombrar una tarea") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancelar") acceptButtonTitle:NSLocalizedString(@"Rename", @"Renombrar")];
    self.createTaskAlertView = [[OCPromptView alloc] initWithPrompt:NSLocalizedString(@"CreateTask", @"Titulo popup para crear una tarea") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancelar") acceptButtonTitle:NSLocalizedString(@"Create", @"Crear")];
    self.startTaskAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StartTask", @"Titulo popup para empezar una tarea") message:NSLocalizedString(@"StartTaskConfirmation", @"Confirmacion para comenzar una tarea") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"Negacion") otherButtonTitles:NSLocalizedString(@"Yes", @"Afirmacion"), nil];
    self.confirmTaskDoneAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Titulo de popup de confirmacion") message:NSLocalizedString(@"TaskDoneConfirmation", @"Texto para la confirmacion de tarea finalizada") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"Negacion") otherButtonTitles:NSLocalizedString(@"Yes", @"Afirmacion"), nil];
    self.continueTaskAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Titulo de popup de confirmacion") message:NSLocalizedString(@"ContinueTaskConfirmation", @"Texto para la confirmacion para continuar una tarea incompleta") delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"Negacion") otherButtonTitles:NSLocalizedString(@"Yes", @"Afirmacion"), nil];
    
    // Antes de obtener la lista de tareas de la base de datos, comprobamos si en las preferencias de la
    // aplicación se ha marcado que deban eliminarse todas o no.
    [self userWantDeleteAllTasks];

    // Obtenemos la lista de tareas incompletas y completas para listarlas.
    self.incompleteTasks = [self.taskDAO listIncompleteTasks];
    self.completedTasks = [self.taskDAO listCompletedTasks];
    
    // Iniciamos los elementos numericos de la cuenta atrás.
    self.countdownMinutes = COUNTDOWN_START_MINUTES;
    self.countdownSeconds = COUNTDOWN_START_SECONDS;
    
    self.countdownLabel.text = [self countdownToNSString];
    
    // Indicamos un pequeño offset a la vista para ocultar por defecto el campo de búsqueda.
    self.taskListTable.contentOffset = CGPointMake(self.taskListTable.contentOffset.x, self.taskListTable.contentOffset.y + 44);
}

- (void)viewDidUnload
{
    [self setTaskListTable:nil];
    [self setPlayImage:nil];
    [self setCommitDeleteAlertView:nil];
    [self setRenameTaskAlertView:nil];
    [self setCreateTaskAlertView:nil];
    [self setStartTaskAlertView:nil];
    [self setConfirmTaskDoneAlertView:nil];
    [self setContinueTaskAlertView:nil];
    [self setTaskDAO:nil];
    [self setIncompleteTasks:nil];
    [self setCompletedTasks:nil];
    [self setPlayImage:nil];
    [self setCountdownStateFile:nil];
    [self setCountdownLabel:nil];
    [self setCountdownTimer:nil];
    [self setSearchTaskBar:nil];
    [self setDisableTaskListImage:nil];
    [self setAudioPlayer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [taskListTable release];
    [playImage release];
    [commitDeleteAlertView release];
    [renameTaskAlertView release];
    [createTaskAlertView release];
    [startTaskAlertView release];
    [confirmTaskDoneAlertView release];
    [continueTaskAlertView release];
    [taskDAO release];
    [incompleteTasks release];
    [completedTasks release];
    [playImage release];
    [countdownStateFile release];
    [countdownLabel release];
    [countdownTimer release];
    [searchTaskBar release];
    [disableTaskListImage release];
    [audioPlayer release];
    [super dealloc];
}

// ---------------------------- Actions -----------------------------------------

- (IBAction)showHideTaskListEditMode:(id)sender {
    [self deactiveSearchBar];
    
    if (!self.countdown) {
        if (self.incompleteTasks.count > 0) {
            [self.taskListTable setEditing:!self.taskListTable.editing animated:YES];
        }
    } else {
        UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskInProcess", @"Texto para indicar que existe una tarea en proceso") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    }
}

- (IBAction)createNewTask:(id)sender {
    [self deactiveSearchBar];

    if (!self.countdown) {
        self.createTaskAlertView.textField.text = @"";
        [self.createTaskAlertView show];
    } else {
        UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskInProcess", @"Texto para indicar que existe una tarea en proceso") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    }
}

- (void)countdown:(NSTimer*)timer {
    self.countdownSeconds--;
    
    if (self.countdownSeconds < 0) {
        self.countdownMinutes--;
        self.countdownSeconds = 59;
    }
    
    if (self.countdownMinutes < 0) {
        self.countdown = NO;
        self.playImage.hidden = YES;
        self.countdownMinutes = COUNTDOWN_START_MINUTES;
        self.countdownSeconds = COUNTDOWN_START_SECONDS;
        self.countdownLabel.text = [self countdownToNSString];
        
        [self stopCountdownAndSaveState];
        
        // Reproducimos la alarma y mostramos un popup de confirmación.
        [self playSound];
        [self.confirmTaskDoneAlertView show];
    }
    
    self.countdownLabel.text = [self countdownToNSString];
}

- (void)userWantDeleteAllTasks {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // Obtenemos el valor de la preferencia encargada de indicar si se deben o no eliminar todas las tareas.
    BOOL deleteAllTasks = [settings boolForKey:@"SettingsDeleteAllTasks"];
    
    // Si así está configurado se prosigue con ellos.
    if (deleteAllTasks) {
        [self.taskDAO removeAllTasks];
        
        // Tras eliminar todas las tareas, se vuelve a la posición por defecto de las preferencias para
        // evitar que la siguiente vez que inicialice la aplicación no se eliminen las tareas, a menos
        // que el usuario vuelva a marcar la opción.
        [settings setBool:NO forKey:@"SettingsDeleteAllTasks"];
    }
    
    // Se añade un observador para controlar el cambio de este variable cuando la aplicación está en segundo
    // plano.
    [[NSNotificationCenter defaultCenter] addObserverForName:NSUserDefaultsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        BOOL deleteAllTasks = [settings boolForKey:@"SettingsDeleteAllTasks"];
        
        // Si así está configurado se prosigue con ellos.
        if (deleteAllTasks) {
            [self.taskDAO removeAllTasks];
            
            // Tras eliminar todas las tareas, se vuelve a la posición por defecto de las preferencias para
            // evitar que la siguiente vez que inicialice la aplicación no se eliminen las tareas, a menos
            // que el usuario vuelva a marcar la opción.
            [settings setBool:NO forKey:@"SettingsDeleteAllTasks"];
            
            // En caso de producirse el cambio por estar la aplicación en segundo plano y no ejecutánse, 
            // debemo recargar las listas.
            self.incompleteTasks = [self.taskDAO listIncompleteTasks];
            self.completedTasks = [self.taskDAO listCompletedTasks];
            [self.taskListTable reloadData];
            
            // Reiniciamos la cuenta atrás en caso de haberla.
            self.countdownMinutes = COUNTDOWN_START_MINUTES;
            self.countdownSeconds = COUNTDOWN_START_SECONDS;
            
            self.countdownLabel.text = [self countdownToNSString];
            
            // Indicamos que no hay ninguna tarea ejecutándose.
            self.countdown = NO;
        }
    }];
}

- (NSString*)countdownToNSString {
    NSString *minutes = [NSString stringWithFormat:@"%d", self.countdownMinutes];
    if (minutes.length < 2) {
        minutes = [NSString stringWithFormat:@"0%@", minutes];
    }
    
    NSString *seconds = [NSString stringWithFormat:@"%d", self.countdownSeconds];
    if (seconds.length < 2) {
        seconds = [NSString stringWithFormat:@"0%@", seconds];
    }
    
    return [NSString stringWithFormat:@"%@:%@", minutes, seconds];
}

- (void)stopCountdownAndSaveState {
    NSMutableDictionary *countdownState = [NSMutableDictionary dictionary];
    [countdownState setObject:[NSNumber numberWithBool:self.countdown] forKey:@"countdown"];
    [countdownState setObject:[NSNumber numberWithInteger:self.countdownMinutes] forKey:@"countdownMinutes"];
    [countdownState setObject:[NSNumber numberWithInteger:self.countdownSeconds] forKey:@"countdownSeconds"];
    [countdownState setObject:[NSNumber numberWithInteger:self.selectedTask] forKey:@"selectedTask"];
    
    [countdownState writeToFile:[self.countdownStateFile stringByAppendingPathComponent:@"taskState.plist"] atomically:YES];
    
    if ([self.countdownTimer isValid]) {
        [self.countdownTimer invalidate];
    }
}

- (void)restartCountdownFromPreviousState {
    NSMutableDictionary *countdownState = [NSMutableDictionary dictionaryWithContentsOfFile:[self.countdownStateFile stringByAppendingPathComponent:@"taskState.plist"]];

    self.countdown = [[countdownState objectForKey:@"countdown"] boolValue];
    if (self.countdown) {
        self.countdownMinutes = [[countdownState objectForKey:@"countdownMinutes"] integerValue];
        self.countdownSeconds = [[countdownState objectForKey:@"countdownSeconds"] integerValue];
        self.selectedTask = [[countdownState objectForKey:@"selectedTask"] integerValue];
        self.countdownLabel.text = [self countdownToNSString];
        
        // Seleccionamos la tarea que teníamos iniciada.
        [self.taskListTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedTask inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        self.continueTaskAlertView.message = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ContinueTaskConfirmation", @"Texto para la confirmacion para continuar una tarea incompleta"), [[self.incompleteTasks objectAtIndex:self.selectedTask] description]];
        
        [self.continueTaskAlertView show];
    }
}

- (void)deactiveSearchBar {
    self.taskListTable.allowsSelection = YES;
    self.taskListTable.scrollEnabled = YES;
    
    [UIView beginAnimations:@"Hide Disable Task List Image" context:nil];
    [UIView setAnimationDuration:0.3];
    
    self.disableTaskListImage.alpha = 0.0;
    
    [UIView commitAnimations];
    
    [self.searchTaskBar resignFirstResponder]; // Ocultamos el teclado en caso de estar mostrándose.
    [self.searchTaskBar setShowsCancelButton:NO animated:YES]; // Al igual que el teclado, ocultamos el botón para cancelar la búsqueda.
}

- (void)playSound {
    if (self.audioPlayer == nil) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Pomodoro Finished" ofType:@"mp3"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath] error:NULL];
        self.audioPlayer.numberOfLoops = -1;
    }
 
    [self.audioPlayer play];
}

- (void)stopSound {
    [self.audioPlayer stop];
    [self.audioPlayer setCurrentTime:0.0];
}

// ---------------------------- Protocolos --------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Dos secciones, una para tareas pendientes y otra para tareas completadas.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = nil;
    
    switch (section) {
        case 0:
            sectionTitle = [[[NSString alloc] initWithFormat:NSLocalizedString(@"IncompleteTask", @"Titulo de seccion de tareas incompletas")] autorelease];
            break;
        case 1:
            sectionTitle = [[[NSString alloc] initWithFormat:NSLocalizedString(@"CompletedTask", @"Titulo de seccion de tareas completadas")] autorelease];
            break;
    }
    
    return sectionTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsInSection = 0;
    
    switch (section) {
        case 0:
            if (self.incompleteTasks != nil) {
                rowsInSection = self.incompleteTasks.count;
            }

            break;
        case 1:
            if (self.completedTasks != nil) {
                rowsInSection = self.completedTasks.count;
            }

            break;
    }
    
    return rowsInSection;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Intentamos obtener una celda reutilizable.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    if (cell == nil) 
    {
        // Si no es posible la creamos.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskCell"]
                autorelease];
    }
    
    // Tras crearla inicializamos valores a mostrar.
    if (indexPath.section == 0) {
        Task* incompleteTask = [self.incompleteTasks objectAtIndex:indexPath.row];
        cell.textLabel.text = incompleteTask.name;
        
        if (self.countdown && (indexPath.row == self.selectedTask)) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 1) {
        Task* completedTask = [self.completedTasks objectAtIndex:indexPath.row];
        cell.textLabel.text = completedTask.name;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
}

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable = YES;
    
    if (indexPath.section == 1) {
        editable = NO;
    }
    
    return editable;
}

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.selectedTask = indexPath.row;
        [self.commitDeleteAlertView show];
    }
}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != destinationIndexPath.section) {
        // Si intentamos realizar un cambio de filas entre las secciones de tareas
        // completada y pendientes, recargamos la lista de datos para devolver
        // la fila a su posición inicial antes de moverla.
        [tableView reloadData];
    } else {
        // Movemos una fila de la posición inicial a la final.
        Task* fromTask = [self.incompleteTasks objectAtIndex:sourceIndexPath.row];
        Task* toTask = [self.incompleteTasks objectAtIndex:destinationIndexPath.row];
        NSString *errorMessages = [self.taskDAO moveTask:fromTask toPositionOfTask:toTask];
        
        if (errorMessages != nil) {
            UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:errorMessages delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
            [errorAlertView show];
            [errorAlertView release];
        } else {
            self.incompleteTasks = [self.taskDAO listIncompleteTasks];
            [self.taskListTable reloadData];
        }
    }
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *selectedRow = nil;
    
    // Evitamos seleccionar una fila en caso de que la cuenta atrás esté activada.
    if (indexPath.section == 0) {
        if (!self.countdown) {
            selectedRow = indexPath;
        } else {
            UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskInProcess", @"Texto para indicar que existe una tarea en proceso") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
            [errorAlertView show];
            [errorAlertView release];
        }
    }
    
    return selectedRow;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deactiveSearchBar];
    
    self.selectedTask = [self.taskListTable indexPathForSelectedRow].row;

    if (indexPath.section == 0) {
        if (self.taskListTable.editing) {
            Task *task = [self.incompleteTasks objectAtIndex:[self.taskListTable indexPathForSelectedRow].row];
            self.renameTaskAlertView.textField.text = task.name;
            [self.renameTaskAlertView show]; 
        } else {
            [self.startTaskAlertView show];
        }
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText == nil || searchText.length == 0) {
        self.incompleteTasks = [self.taskDAO listIncompleteTasks];
        self.completedTasks = [self.taskDAO listCompletedTasks];
    } else {
        self.incompleteTasks = [self.taskDAO listIncompleteTasksWithName:searchText];
        self.completedTasks = [self.taskDAO listCompletedTasksWithName:searchText];
    }

    [self.taskListTable reloadData];
}

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (self.countdown) {
        UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskInProcess", @"Texto para indicar que existe una tarea en proceso") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
        [errorAlertView show];
        [errorAlertView release];
    } else {
        [UIView beginAnimations:@"Show Disable Task List Image" context:nil];
        [UIView setAnimationDuration:0.3];
        
        self.disableTaskListImage.alpha = 1.0;
        
        [UIView commitAnimations];
        
        self.taskListTable.allowsSelection = NO;
        self.taskListTable.scrollEnabled = NO;
        [searchBar setShowsCancelButton:YES animated:YES];
    }
    
    return !self.countdown;
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self deactiveSearchBar];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self deactiveSearchBar];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Filtramos las acciones según el alertView que mostremos
    if (alertView == self.commitDeleteAlertView) {
        switch (buttonIndex) {
            case 1: // Eliminamos la tarea.
                NSLog(@"Eliminamos tarea");
                Task *task = [self.incompleteTasks objectAtIndex:self.selectedTask];
                NSString *errorMessages = [self.taskDAO removeTask:task];
                
                if (errorMessages != nil) {
                    UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:errorMessages delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                    [errorAlertView show];
                    [errorAlertView release];
                } else {
                    self.incompleteTasks = [self.taskDAO listIncompleteTasks];
                    [self.taskListTable reloadData];
                }
                
                break;
        }
    } else if (alertView == self.createTaskAlertView) {
        switch (buttonIndex) {
            case 1: // Creamos la tarea.
                if (self.createTaskAlertView.textField.text == nil || self.createTaskAlertView.textField.text.length == 0) {
                    UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskCannotBeEmpty", @"Texto para indicar que el nombre de una tarea no puede ser vacia") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                    [errorAlertView show];
                    [errorAlertView release];
                } else {
                    NSLog(@"Creamos tarea");
                    NSString *taskName = [NSString stringWithString:self.createTaskAlertView.textField.text];
                    Task *newTask = [[Task alloc] initWithName:taskName];
                    NSString *errorMessages = [self.taskDAO addTask:newTask];
                    
                    if (errorMessages != nil) {
                        UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:errorMessages delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                        [errorAlertView show];
                        [errorAlertView release];
                    } else {
                        self.incompleteTasks = [self.taskDAO listIncompleteTasks];
                        [self.taskListTable reloadData];
                    }
                    
                    [newTask release];
                }

                break;
        }
    } else if (alertView == self.startTaskAlertView) {
        switch (buttonIndex) {
            case 0:
                // Evitamos que una tarea se quede seleccionada.
                [self.taskListTable deselectRowAtIndexPath:[self.taskListTable indexPathForSelectedRow] animated:YES];
                
                break;
            case 1: // Iniciamos la tarea.
                NSLog(@"Iniciamos tarea");
                self.countdown = YES;
                self.playImage.hidden = NO;

                // Evitamos que el dispositivo se autobloquee para no detener de esta forma el contador por inactividad.
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                
                [self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedTask inSection:0]].accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
                
                break;
        }
    } else if (alertView == self.renameTaskAlertView) {
        switch (buttonIndex) {
            case 1: // Renombramos la tarea.
                NSLog(@"Renombramos tarea");
                if (self.renameTaskAlertView.textField.text == nil || self.renameTaskAlertView.textField.text.length == 0) {
                    UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:NSLocalizedString(@"TaskCannotBeEmpty", @"Texto para indicar que el nombre de una tarea no puede ser vacia") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                    [errorAlertView show];
                    [errorAlertView release];
                } else {
                    Task *task = [self.incompleteTasks objectAtIndex:self.selectedTask];
                    task.name = self.renameTaskAlertView.textField.text;
                    NSString *errorMessages = [self.taskDAO updateTask:task];
                    
                    if (errorMessages != nil) {
                        UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:errorMessages delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                        [errorAlertView show];
                        [errorAlertView release];
                    } else {
                        self.incompleteTasks = [self.taskDAO listIncompleteTasks];
                        [self.taskListTable reloadData];
                    }
                }
                break;
        }
        
        // Evitamos que una tarea se quede seleccionada.
        [self.taskListTable deselectRowAtIndexPath:[self.taskListTable indexPathForSelectedRow] animated:YES];
    } else if (alertView == self.confirmTaskDoneAlertView) {
        // Al terminar una tarea se vuelve a activar el autobloqueo del dispositivo.
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        // Y detenemos la alerta.
        [self stopSound];
        
        switch (buttonIndex) {
            case 0:
                [self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedTask inSection:0]].accessoryType = UITableViewCellAccessoryNone;

                break;
            case 1: // Confirmamos fin de tarea.
                NSLog(@"Confirmamos fin de tarea");
                Task *task = [self.incompleteTasks objectAtIndex:self.selectedTask];
                task.done = YES;
                NSString *errorMessages = [self.taskDAO updateTask:task];
                
                if (errorMessages != nil) {
                    UIAlertView* errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Titulo del popup de error") message:errorMessages delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Ok") otherButtonTitles:nil];
                    [errorAlertView show];
                    [errorAlertView release];
                } else {
                    self.incompleteTasks = [self.taskDAO listIncompleteTasks];
                    self.completedTasks = [self.taskDAO listCompletedTasks];
                    [self.taskListTable reloadData];
                }
                
                break;
        }
        
        // Evitamos que una tarea se quede seleccionada.
        [self.taskListTable deselectRowAtIndexPath:[self.taskListTable indexPathForSelectedRow] animated:YES];
    } else if (alertView == self.continueTaskAlertView) {
        switch (buttonIndex) {
            case 0:
                self.countdown = NO;
                self.playImage.hidden = YES;
                self.countdownMinutes = COUNTDOWN_START_MINUTES;
                self.countdownSeconds = COUNTDOWN_START_SECONDS;
                self.countdownLabel.text = [self countdownToNSString];
                
                // Evitamos que una tarea se quede seleccionada.
                [self.taskListTable deselectRowAtIndexPath:[self.taskListTable indexPathForSelectedRow] animated:YES];
                
                // Vuelve a activar el autobloqueo del dispositivo.
                [UIApplication sharedApplication].idleTimerDisabled = NO;
                
                [self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedTask inSection:0]].accessoryType = UITableViewCellAccessoryNone;
                
                [self stopCountdownAndSaveState];

                break;
            case 1: // Continuamos la última tarea incompleta.
                NSLog(@"Continuamos la última tarea incompleta");
                self.playImage.hidden = NO;
                
                // Evitamos que el dispositivo se autobloquee para no detener de esta forma el contador por inactividad.
                [UIApplication sharedApplication].idleTimerDisabled = YES;
                
                [self.taskListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedTask inSection:0]].accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:YES];
                
                break;
        }
    }
}

@end
