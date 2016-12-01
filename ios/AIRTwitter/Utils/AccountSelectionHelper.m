/**
 * Copyright 2015-2016 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AccountSelectionHelper.h"
#import "AIRTwitterEvent.h"
#import "AIRTwitter.h"

static accountSelectorCallback mAIRTwitterAccountSelectorCallback;
static ACAccountStore* mAIRTwitterAccountStore;

@implementation AccountSelectionHelper

+ (void) selectAccount:(accountSelectorCallback) completionHandler {
    mAIRTwitterAccountStore = [[ACAccountStore alloc] init];

    mAIRTwitterAccountSelectorCallback = completionHandler;
    
    ACAccountType* accountType = [mAIRTwitterAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    /* Ask user for access to Twitter accounts in the system */
    [mAIRTwitterAccountStore requestAccessToAccountsWithType:accountType options:nil completion:^( BOOL granted, NSError* error ) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if( error ) {
                mAIRTwitterAccountSelectorCallback( nil, NO, error.localizedDescription );
                [self dispose];
                return;
            }
            
            /* Access not granted */
            if( !granted ) {
                mAIRTwitterAccountSelectorCallback( nil, NO, @"Acccess to Twitter accounts was not granted." );
                [self dispose];
                return;
            }
            
            NSArray* twitterAccounts = [mAIRTwitterAccountStore accountsWithAccountType:accountType];
            
            /* Check if a Twitter account is set */
            if( twitterAccounts.count == 0 ) {
                mAIRTwitterAccountSelectorCallback( nil, NO, @"No Twitter account is set in the system." );
                [self dispose];
                return;
            }
            
            /* If single account is set, use that */
            if( twitterAccounts.count == 1 ) {
                ACAccount* account = [twitterAccounts lastObject];
                mAIRTwitterAccountSelectorCallback( account, NO, nil );
                [self dispose];
            }
            /* Otherwise let the user pick one */
            else {
                /* iOS 8+ alert */
                if( NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ) {
                    [self showiOS8ActionSheet:twitterAccounts];
                }
                /* iOS 7 alert */
                else {
                    [self showiOS7ActionSheet:twitterAccounts];
                }
            }
        }];
    }];
}

+ (void) showiOS8ActionSheet:(NSArray*) twitterAccounts {
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Select an account:"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    UIPopoverPresentationController* ppc = [ac popoverPresentationController];
    ppc.sourceView = [[UIApplication sharedApplication] delegate].window;
    /* Cancel button */
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [AIRTwitter log:@"Account selection was cancelled."];
        mAIRTwitterAccountSelectorCallback( nil, YES, nil );
        [self dispose];
    }]];
    /* Buttons for available accounts */
    for( ACAccount* account in twitterAccounts ) {
        [ac addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"@%@", account.username] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            mAIRTwitterAccountSelectorCallback( account, NO, nil );
            [self dispose];
        }]];
    }
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController]presentViewController:ac animated:YES completion:nil];
}

+ (void) showiOS7ActionSheet:(NSArray*) twitterAccounts {
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil otherButtonTitles:nil];
    for( ACAccount* account in twitterAccounts ) {
        [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
    }
    [as showInView:[[UIApplication sharedApplication] delegate].window];
}

#pragma mark UIActionSheetDelegate

+ (void) actionSheet:(UIActionSheet*) actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex {
    if( buttonIndex == [actionSheet cancelButtonIndex] ) {
        mAIRTwitterAccountSelectorCallback( nil, YES, nil );
        [self dispose];
        return;
    }

    NSUInteger accountIndex = buttonIndex - 1;
    ACAccountType* accountType = [mAIRTwitterAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount* account = [mAIRTwitterAccountStore accountsWithAccountType:accountType][accountIndex];

    mAIRTwitterAccountSelectorCallback( account, NO, nil );
    [self dispose];
}

+ (void) dispose {
    mAIRTwitterAccountSelectorCallback = nil;
    mAIRTwitterAccountStore = nil;
}

@end
