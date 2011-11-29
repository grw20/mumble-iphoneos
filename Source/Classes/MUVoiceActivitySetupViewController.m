/* Copyright (C) 2009-2011 Mikkel Krautz <mikkel@krautz.dk>

   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.
   - Neither the name of the Mumble Developers nor the names of its
     contributors may be used to endorse or promote products derived from this
     software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "MUVoiceActivitySetupViewController.h"
#import "MUTableViewHeaderLabel.h"
#import "MUAudioBarViewCell.h"
#import "MUColor.h"

@implementation MUVoiceActivitySetupViewController

- (id) init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // ...
    }
    return self;
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundTextureBlackGradient"]] autorelease];
    self.navigationItem.title = @"Voice Activity";
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    if (section == 1)
        return 1;
    if (section == 2)
        return 2;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *current = [[NSUserDefaults standardUserDefaults] stringForKey:@"AudioVADKind"];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Amplitude";
            if ([current isEqualToString:@"amplitude"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.textLabel.textColor = [MUColor selectedTextColor];
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Signal to Noise";
            if ([current isEqualToString:@"snr"]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.textLabel.textColor = [MUColor selectedTextColor];
            }
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MUAudioBarViewCell *cell = [[[MUAudioBarViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AudioBarCell"] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Silence Below";
            UISlider *slider = [[UISlider alloc] init];
            [slider setMinimumValue:0.0f];
            [slider setMaximumValue:1.0f];
            [slider addTarget:self action:@selector(vadBelowChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"AudioVADBelow"] floatValue]];
            [slider setMaximumTrackTintColor:[UIColor blackColor]];
            [slider setMinimumTrackTintColor:[UIColor blackColor]];
            cell.accessoryView = slider;
            [slider release];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Speech Above";
            UISlider *slider = [[UISlider alloc] init];
            [slider setMinimumValue:0.0f];
            [slider setMaximumValue:1.0f];
            [slider addTarget:self action:@selector(vadAboveChanged:) forControlEvents:UIControlEventValueChanged];
            [slider setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"AudioVADAbove"] floatValue]];
            [slider setMaximumTrackTintColor:[UIColor blackColor]];
            [slider setMinimumTrackTintColor:[UIColor blackColor]];
            cell.accessoryView = slider;
            [slider release];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [MUTableViewHeaderLabel labelWithText:@"Method"];
    } else if (section == 1) {
        return [MUTableViewHeaderLabel labelWithText:@"Configuration"];
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [MUTableViewHeaderLabel defaultHeaderHeight];
    } else if (section == 1) {
        return [MUTableViewHeaderLabel defaultHeaderHeight];
    }
    return 0.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    // Transmission setting change
    if (indexPath.section == 0) {
        for (int i = 0; i < 2; i++) {
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = [UIColor blackColor];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"amplitude" forKey:@"AudioVADKind"];
        } else if (indexPath.row == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:@"snr" forKey:@"AudioVADKind"];
        }
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [MUColor selectedTextColor];
    }
}

#pragma mark - Actions

- (void) vadBelowChanged:(UISlider *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[sender value]] forKey:@"AudioVADBelow"];
}

- (void) vadAboveChanged:(UISlider *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[sender value]] forKey:@"AudioVADAbove"];
}

@end
