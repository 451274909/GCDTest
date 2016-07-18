//
//  ViewController.m
//  GCD
//
//  Created by jota on 16/7/18.
//  Copyright © 2016年 YY. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testSerialQueueWithAsync];
    [self testConcurrentQueueWithAsync];
//    [self testDispatch_group];
    

}

//dispatch_async 中使用串行队列
- (void)testSerialQueueWithAsync {

    //自定义一个串行队列
    dispatch_queue_t serial_queue = dispatch_queue_create("com.yangyuan.www", DISPATCH_QUEUE_SERIAL);
    
    for (int index = 0; index < 10; index++) {
        dispatch_async(serial_queue, ^{
            NSLog(@"index = %d", index);
            NSLog(@"current thread is %@", [NSThread currentThread]);
        });
    }
    NSLog(@"run on main thread");
}
/*
 1.  dispatch_async 中使用的所有的 Thread 均为同一个 Thread 因为指针地址完全相同
 2.  输出结果顺序输出 符合我们队串行队列的期待 即FIFO, 先进先出
 3. Running on main Thread 这句话并没有在最后执行, 而是会出现在随机位置, 这也符合我们对 dispatch_async 的期待, 因为他会开辟一个新线程, 不会阻碍主线程.
 */

//dispatch_async 中使用并行队列
- (void)testConcurrentQueueWithAsync {

    //自定义一个并行队列
    dispatch_queue_t concurrent_queue = dispatch_queue_create("com.yangyuan.www", DISPATCH_QUEUE_CONCURRENT);
    
    for (int index = 0; index < 10; index++) {
        dispatch_async(concurrent_queue, ^{
            NSLog(@"index = %d", index);
            NSLog(@"current thread is %@", [NSThread currentThread]);
        });
    }
    NSLog(@"run on main thread");
}
/*
 1. 输出结果是乱序的, 说明输出结果是并发的, 有多个线程并发执行.
 2. run on main thread 这句话依然没有被阻塞.
 3. 每次打印出的 thread 均不相同.
    1. 串行队列如何在异步线程中遵守先进先出原则?
    因为他会保证每次 dispatch_async 开辟新线程执行串行队列中的任务时, 总是使用同一个异步线程, 这就是为什么我们第一次打印结果 nsthread 总是相同.
    2. dispatch_async 中放入并行队列执行任务时, 为什么执行顺序总是乱序的?
    因为在并行队列中, 每执行一次任务, dispatch_async 就会开辟一个新线程(开辟线程总量是有限制的)来执行任务的, 所以不同线程开始结束的时间都不一样, 导致了结果是乱序的.
 */

- (void)testDispatch_group {
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    dispatch_group_enter(serviceGroup);
    NSLog(@"this is first task");
    dispatch_group_leave(serviceGroup);
    
    dispatch_group_enter(serviceGroup);
    NSLog(@"this is second task");
    dispatch_group_leave(serviceGroup);
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(), ^{
        NSLog(@"all task is finish");
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
