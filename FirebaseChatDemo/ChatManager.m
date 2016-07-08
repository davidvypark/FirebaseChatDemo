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
	
	// Observe for any value changes at this endpoint
	[chatReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if (snapshot.value && [snapshot.value isKindOfClass:[NSDictionary class]]) {
			
			NSDictionary *valueDictionary = (NSDictionary *)snapshot.value;
			
			NSLog(@"Value Dictionary: %@", valueDictionary);
			
			// Add any new messages
			[self _addMessagesFromArray:valueDictionary.allValues];
	
			[self _alertDelegates];
		}
	}];
}

- (void)sendMessageFromSender:(NSString *)senderName withContent:(NSString *)content
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

/**
 Adds any new messages pulled from Firebase. (i.e., only messages containing message ids that the current messages array does not have)
 */
- (void)_addMessagesFromArray:(NSArray *)messageArray
{
	for (NSDictionary *messageDictionary in messageArray) {
		NSPredicate *messageIdPredicate = [NSPredicate predicateWithFormat:@"self.messageId == %@", messageDictionary[kMessageIdKey]];
		NSArray *filteredArray = [self.messages filteredArrayUsingPredicate:messageIdPredicate];
		if (filteredArray.count == 0) {
			// new message, add it to the array
			[self.messages addObject:[self _createMessageFromDictionary:messageDictionary]];
		}
	}
}

- (Message *)_createMessageFromDictionary:(NSDictionary *)dictionary
{
	Message *newMessage = [[Message alloc] initWithSenderName:dictionary[kSenderNameKey]
																										content:dictionary[kContentKey]
																									messageID:dictionary[kMessageIdKey]];
	return newMessage;
}



@end
