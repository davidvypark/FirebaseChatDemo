//
//  Message.h
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

/**
 @abstract Name of the sender of this message
 */
@property (nonatomic, strong, readonly) NSString *senderName;

/**
 @abstract The actual contents of the message
 */
@property (nonatomic, strong, readonly) NSString *content;

/**
 @abstract The Unique id for this message
 */
@property (nonatomic, strong, readonly) NSString *messageId;

- (instancetype)initWithSenderName:(NSString *)senderName content:(NSString *)content messageID:(NSString *)messageId;

@end
