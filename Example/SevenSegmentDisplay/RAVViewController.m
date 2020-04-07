//
//  RAVViewController.m
//  SevenSegmentDisplay
//
//  Created by RochevAV on 03/20/2020.
//  Copyright (c) 2020 RochevAV. All rights reserved.
//

#import "RAVViewController.h"
#import <SevenSegmentDisplay/RAVSegmentDisplayView.h>

@interface RAVViewController ()

@property (weak, nonatomic) IBOutlet RAVSegmentDisplayView *displayView;

@end

@implementation RAVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.displayView setIntegerValue: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
