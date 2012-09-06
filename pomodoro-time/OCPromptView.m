//
//  OCPromptView.m
//  Pomodoro Time
//
//  Created by Cody on http://www.iostipsandtricks.com/using-uialertview-as-a-text-prompt/
//  Copyright 2011 -. All rights reserved.
//

#import "OCPromptView.h"

@implementation OCPromptView

@synthesize textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
    while ([prompt sizeWithFont:[UIFont systemFontOfSize:18.0]].width > 240.0) {
        prompt = [NSString stringWithFormat:@"%@...", [prompt substringToIndex:[prompt length] - 4]];
    }
    if (self = [super initWithTitle:prompt message:@"\n" delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil]) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)]; 
        [theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        [theTextField setBorderStyle:UITextBorderStyleRoundedRect];
        
        // Comprobamos la versión del SO del dispositivo para utilizar
        // un color u otro para el fondo del campo de texto ya que no
        // funciona igual para versiones anteriores a 5.0 y esta.
        float version = [[[UIDevice currentDevice]systemVersion]floatValue];
        if(version < 5.0)
        {
            [theTextField setBackgroundColor:[UIColor clearColor]];
        }else
        {
            [theTextField setBackgroundColor:[UIColor whiteColor]];
        }

        [theTextField setTextAlignment:UITextAlignmentLeft];
        
        [self addSubview:theTextField];
        
        self.textField = theTextField;
        [theTextField release];
    }
    
    return self;
}

- (void)show {
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return textField.text;
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}

@end
