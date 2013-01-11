//
//  NoteCardRootVC.m
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import "NoteCardRootVC.h"

@interface NoteCardRootVC ()

@end

@implementation NoteCardRootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayText:(NSString *)text
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.displayText = text;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.displayLabel.text = self.displayText;
    
    UIImage *image = [UIImage imageNamed:[self.info objectForKey:@"image"]];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitle:[self.info objectForKey:@"title"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDisplayLabel:nil];
    [super viewDidUnload];
}
@end
