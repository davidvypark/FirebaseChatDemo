//
//  Message.m
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)init
{
	return [self initWithSenderName:@"NO NAME" content:@"EMPTY CONTENT" messageID:@"EMPTY ID"];
}

- (instancetype)initWithSenderName:(NSString *)senderName content:(NSString *)content messageID:(NSString *)messageId
{
	if (!(self = [super init])) {
		return nil;
	}
	
	_senderName = senderName;
	_content = content;
	_messageId = messageId;
	
	return self;
}

@end
