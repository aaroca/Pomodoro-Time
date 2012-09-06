//
//  OCPromptView.h
//  Pomodoro Time
//
//  Created by Cody on http://www.iostipsandtricks.com/using-uialertview-as-a-text-prompt/
//  Copyright 2011 -. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCPromptView : UIAlertView {
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;
- (NSString *)enteredText;

@end
