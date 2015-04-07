//
//  AddressBookHelper.h
//  Screen
//
//  Created by Mason Wolters on 1/11/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class PFUser;

typedef void(^AddressBookBlock)(ABAddressBookRef addressBook);
typedef void(^NothingBlock)(void);
typedef void(^PhoneBlock)(NSString *phoneNumber);

@interface AddressBookHelper : NSObject

+ (void)phoneNumberForUser:(PFUser *)user success:(PhoneBlock)success error:(NothingBlock)error;
+ (void)addressBook:(AddressBookBlock)success denied:(NothingBlock)denied;

@end
