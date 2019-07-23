//
//  FirstViewController.m
//  SocketDemo
//
//  Created by Mac on 2019/7/22.
//  Copyright © 2019年 Mac. All rights reserved.
//

#import "FirstViewController.h"
#import "GCDAsyncSocket.h"
#import "SocketManager.h"
#define IP @"127.0.0.1"

@interface FirstViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textView;
@property (weak, nonatomic) IBOutlet UITextView *showContent;

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSTimer  *heartTimer;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)connectAction:(id)sender {
    //创建 socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket disconnect];
    
    NSLog(@"客户端socket = %@",self.socket);
    //与服务器socket连接起来
    NSError *error = nil;
    BOOL result = [self.socket connectToHost:IP onPort:54321 error:&error];
    
    //判断是否成功
    if (result) {
        [self addText:@"客户端链接服务器成功"];
    }else {
        [self addText:@"客户端链接服务器失败"];
    }
    
    if (error) {
         NSLog(@"客户端错误是%@",error);
    }
    
}
- (IBAction)sendAction:(id)sender {
    
    [self.socket writeData:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self addText:@"客户端已经发送信息"];
    SocketManager *socket = [SocketManager defaultSocketManager];
    [socket.serverSocket readDataWithTimeout:-1 tag:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// textView填写内容
- (void)addText:(NSString *)text
{
    self.showContent.text = [self.showContent.text stringByAppendingFormat:@"\n%@\n\n", text];
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self addText:[NSString stringWithFormat:@"链接服务器%@ port= %d", host,port]];
    
    //将客户端socket 存到单例
    
    SocketManager    *socket = [SocketManager defaultSocketManager];
    socket.clientSocket = sock;
    
    self.socket  = sock;
    
    self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(sendHeartMessage:) userInfo:nil repeats:YES];
    
}

- (void)sendHeartMessage:(NSTimer *)timer
{
    //此处填写自己的一个心跳包发送,
    NSString *heart = @"Damon";
    NSData *data= [heart dataUsingEncoding:NSUTF8StringEncoding];
//    [self.socket writeData:data withTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开链接");
    [self.heartTimer invalidate];
    self.heartTimer = nil;
    
    if (err) {
        [self.socket connectToHost:IP onPort:54321 error:nil];
    }else{
        [self.socket  disconnect];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self addText:content];
}

@end
