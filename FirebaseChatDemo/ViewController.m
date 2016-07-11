//
//  ViewController.m
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import "ViewController.h"
#import "ChatManager.h"
#import <POP/POP.h>



@interface ViewController ()

typedef enum MessageBarPosition
{
	BarPositionUp,
	BarPositionDown
} MessageBarPosition;

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBarViewBottomOffsetContraint;


@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	
	[self _setupKeyboard];
}

#pragma mark - Sending Messages

- (IBAction)_sendButtonTapped:(id)sender
{
	if (self.messageTextField.text.length == 0) {
		return;
	}
	
	[[ChatManager sharedManager] sendMessageFrom:[UIDevice currentDevice].name
																				 withContent:self.messageTextField.text];
	self.messageTextField.text = @"";
}

#pragma mark - Bottom Message Bar & Keyboard


- (void)_setupKeyboard
{
	// Register for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(_raiseMessageBar:)
																							 name:UIKeyboardWillShowNotification
																						 object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
																					 selector:@selector(_lowerMessageBar:)
																							 name:UIKeyboardWillHideNotification
																						 object:nil];
	
	
	// Tap gesture recognizer to dismiss keyboard
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
																																							 action:@selector(_dismissKeyboard)];
	[self.view addGestureRecognizer:tapGesture];
	
	
	
}

- (void)_dismissKeyboard
{
	if ([self.messageTextField isFirstResponder]) {
		[self.messageTextField resignFirstResponder];
	}
}

- (void)_raiseMessageBar:(NSNotification *)notification
{
	[self _moveMessageBarToPosition:BarPositionUp notification:notification];
}

- (void)_lowerMessageBar:(NSNotification *)notification
{
	[self _moveMessageBarToPosition:BarPositionDown notification:notification];
}

- (void)_moveMessageBarToPosition:(MessageBarPosition)barPosition notification:(NSNotification *)notification
{
	CGFloat toValue = 0;
	if (barPosition == BarPositionUp) {
		toValue = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	}
	
	POPSpringAnimation *moveAnim = [self.messageBarViewBottomOffsetContraint pop_animationForKey:@"MoveAnimation"];
	if (moveAnim) {
		moveAnim.toValue = @(toValue);
	}
	else {
		moveAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
		moveAnim.toValue = @(toValue);
		[self.messageBarViewBottomOffsetContraint pop_addAnimation:moveAnim forKey:@"MoveAnimation"];
	}
}



@end
