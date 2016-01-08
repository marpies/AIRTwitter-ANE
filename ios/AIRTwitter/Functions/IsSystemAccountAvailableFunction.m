/**
 * Copyright 2015 Marcel Piestansky (http://marpies.com)
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

#import "IsSystemAccountAvailableFunction.h"
#import "MPFREObjectUtils.h"
#import <Accounts/Accounts.h>
#import "MPFREObjectUtils.h"
#import "AIRTwitter.h"

FREObject tw_isSystemAccountAvailable( FREContext context, void* functionData, uint32_t argc, FREObject* argv ) {
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray* twitterAccounts = [accountStore accountsWithAccountType:accountType];
    [AIRTwitter log:[NSString stringWithFormat:@"Number of Twitter accounts available: %lu", twitterAccounts.count]];
    return [MPFREObjectUtils getFREObjectFromBOOL:twitterAccounts.count > 0];
}