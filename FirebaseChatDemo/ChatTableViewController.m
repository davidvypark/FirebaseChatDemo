//
//  ChatTableViewController.m
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatManager.h"
#import "Message.h"

@interface ChatTableViewController () <ChatManagerDelegate>

@property (nonatomic, strong) ChatManager *chatManager;

@end

@implementation ChatTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self _setupBackgroundAppearance];
	self.chatManager = [ChatManager sharedManager];
	self.chatManager.delegate = self;
}

- (void)_setupBackgroundAppearance
{
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.chatManager.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Check out the object for this cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
	
	// Get the message for this chat
	Message *message = self.chatManager.messages[indexPath.row];
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", message.senderName, message.content];
	
	return cell;
}

#pragma mark - Chat Manager Delegate

- (void)messagesDidUpdate
{
	[self.tableView reloadData];
}


@end
