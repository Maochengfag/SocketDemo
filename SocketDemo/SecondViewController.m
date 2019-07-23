//
//  SecondViewController.m
//  SocketDemo
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019年 Mac. All rights reserved.
//

#import "SecondViewController.h"
#import "SocketManager.h"
#define IP  @"127.0.0.1"

#import "GCDAsyncSocket.h"

@interface SecondViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic,strong) GCDAsyncSocket *socket;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)listenMsgAction:(id)sender {
    //1.创建socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //2.端口监听
    NSError *error = nil;
    BOOL result  = [self.socket acceptOnPort:54321 error:&error];
    //3.判断连接是否成功
    if (result) {
        [self addText:@"端口开放成功"];
    }else{
        [self addText:@"端口开放失败"];
    }
}

- (IBAction)sendAction:(id)sender {
    [self addText:@"发送信息成功"];
    [self.socket writeData:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //默认发出的socket信息,客户端并不会直接就调用socketDidRead,而是需要主动去目标栈里面去读取,此处使用单利manger主动去获取
    SocketManager *socket = [SocketManager defaultSocketManager];
    [socket.clientSocket readDataWithTimeout:-1 tag:0];
}


/*
 在这个方法中打印socket 可以发现和初始化socket区别
 */

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    [self addText:@"链接成功"];
    
    [self addText:[NSString stringWithFormat:@"sock 链接地址:%@",sock.connectedHost]];
    [self addText:[NSString stringWithFormat:@"sock 端口号:%hu",sock.connectedPort]];
    
    //newSocket
    [self addText:[NSString stringWithFormat:@"new链接地址:%@",newSocket.connectedHost]];
    [self addText:[NSString stringWithFormat:@"new端口号:%hu",newSocket.connectedPort]];
    
    //将服务器端通信socket存到单例,
    SocketManager *socket = [SocketManager defaultSocketManager];
    socket.serverSocket = newSocket;
    
    self.socket = newSocket;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addText:(NSString *)textString{
    self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@\n",textString];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self addText:content];
}


@end
