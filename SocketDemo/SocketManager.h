//
//  SocketManager.h
//  SocketDemo
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

+ (SocketManager *)defaultSocketManager;

@end
