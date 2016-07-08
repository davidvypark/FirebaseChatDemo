//
//  ChatManager.h
//  FirebaseChatDemo
//
//  Created by Matt Amerige on 7/7/16.
//  Copyright © 2016 mamerige. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatManagerDelegate <NSObject>

/**
 Called whenever the chat manager receives a new message
 */
- (void)messagesDidUpdate;

@end

@interface ChatManager : NSObject

/**
 @abstract Array containing all the messages in the chat.
 */
@property (nonatomic, strong, readonly) NSMutableArray *messages;

/**
 @abstract Delegates of the ChatManager can receive chat updates
 */
@property (nonatomic, weak) id<ChatManagerDelegate> delegate;

/**
 @abstract Shared instane of the Chat Manager
 */
+ (instancetype)sharedManager;

/**
 @abstract Connects this device to the Firebase chat database
 */
- (void)connect;

/**
 @abstract Sends a message to the database.}
 */
- (void)sendMessageFromSender:(NSString *)senderName withContent:(NSString *)content;

@end
