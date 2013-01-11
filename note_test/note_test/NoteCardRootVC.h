//
//  NoteCardRootVC.h
//  note_test
//
//  Created by lili on 13-1-9.
//  Copyright (c) 2013年 lili. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCardRootVC : UIViewController

@property (copy,nonatomic)NSString *displayText;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property (nonatomic, strong) NSDictionary* info;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayText:(NSString *)text;
@end
