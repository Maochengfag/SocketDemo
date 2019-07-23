//
//  SocketManager.m
//  SocketDemo
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019年 Mac. All rights reserved.
//

#import "SocketManager.h"

@implementation SocketManager

+ (SocketManager *)defaultSocketManager{
    
    static SocketManager *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [[SocketManager alloc] init];
    });
    
    return socket;
}

@end
