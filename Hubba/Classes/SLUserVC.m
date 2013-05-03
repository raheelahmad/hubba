//
//  SLUserVC.m
//  Hubba
//
//  Created by Raheel Ahmad on 4/24/13.
//  Copyright (c) 2013 Sakun Labs. All rights reserved.
//

#import "SLUserVC.h"
#import "SLUser.h"
#import "UIImageView+Remote.h"

@interface SLUserVC ()
@property (strong, nonatomic) IBOutlet UILabel *loginLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@end

@implementation SLUserVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:@"SLUserVC" bundle:nil];
	if (self) {
		
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.loginLabel.text = self.user.login;
	self.emailLabel.text = self.user.email;
	[self.avatarImageView setupWithImageAtURL:self.user.avatarURL];
}

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES
							 completion:nil];
}
@end
