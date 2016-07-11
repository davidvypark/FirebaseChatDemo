//
//  ChatManager.m
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import "ChatManager.h"
#import <Firebase/Firebase.h>
#import "Message.h"

@interface ChatManager ()

@property (nonatomic, strong, readwrite) NSMutableArray *messages; // Array of Message instances

@end

static const NSString *kSenderNameKey = @"Sender Name";
static const NSString *kContentKey = @"Content";
static const NSString *kMessageIdKey = @"Message Id";

@implementation ChatManager

+ (instancetype)sharedManager
{
	static ChatManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[ChatManager alloc] init];
	});
	
	return sharedInstance;
}

- (instancetype)init
{
	if (!(self = [super init])) {
		return nil;
	}
	
	_messages = [[NSMutableArray alloc] init];
	
	return self;
}

#pragma mark - PUBLIC

- (void)connect
{
	// Create a reference to the messages path
	FIRDatabaseReference *chatReference = [[FIRDatabase database] referenceWithPath:@"/messages"];
	
	// Listen for new messages
	[self _listenForNewMessagesWithReference:chatReference];
	
	// Listen for deleted messages
	[self _listenForDeletedMessagesWithReference:chatReference];
}

- (void)sendMessageFrom:(NSString *)senderName withContent:(NSString *)content
{
	NSDictionary *messageInfo = @{kSenderNameKey : senderName,
																kContentKey : content,
																kMessageIdKey : [[NSUUID UUID] UUIDString]};
	
	
	// Get a reference to the messages path and adds a child node
	FIRDatabaseReference *chatReference = [[[FIRDatabase database] referenceWithPath:@"/messages"] childByAutoId];
	
	[chatReference setValue:messageInfo];
}

#pragma mark - PRIVATE

- (void)_alertDelegates
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(messagesDidUpdate)]) {
		[self.delegate messagesDidUpdate];
	}
	else {
		NSLog(@"Delegate not set or does not respond to messagesDidUpdate");
	}
}

- (void)_listenForNewMessagesWithReference:(FIRDatabaseReference *)chatReference
{
	[chatReference observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		
		if (snapshot.value) {
			// Casting the value to a dictionary
			NSDictionary *data = (NSDictionary *)snapshot.value;
			
			// Create a new message with the contents of the dictionary
			Message *newMessage = [self _createMessageFromDictionary:data];
			
			// Add the new message to our array of messages
			[self.messages addObject:newMessage];
			
			// Alert delegates of any changes
			[self _alertDelegates];
		}
	}];
}

- (void)_listenForDeletedMessagesWithReference:(FIRDatabaseReference *)chatReference
{
	[chatReference observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if (snapshot.value) {
			// Create a Message object from the data received from the database
			Message *messageToRemove = [self _createMessageFromDictionary:snapshot.value];
			
			// Create a predicate to filter the array.
			// We can a new array containing all messages that do NOT match the messageId of the message are removing
			NSPredicate *removeMessagePredicate = [NSPredicate predicateWithFormat:@"self.messageId != %@",
																						 messageToRemove.messageId];
			
			// Filtering the array with the predicate.
			// This should leave only the messages that we care about, removing the deleted message from the array.
			[self.messages filterUsingPredicate:removeMessagePredicate];
			
			// Alert the delegate of any changes
			[self _alertDelegates];
		}
	}];
}

- (Message *)_createMessageFromDictionary:(NSDictionary *)dictionary
{
	Message *newMessage = [[Message alloc] initWithSenderName:dictionary[kSenderNameKey]
																										content:dictionary[kContentKey]
																									messageID:dictionary[kMessageIdKey]];
	return newMessage;
}



@end
