//
//  AddressBookHelper.m
//  Screen
//
//  Created by Mason Wolters on 1/11/15.
//  Copyright (c) 2015 Big Head Applications. All rights reserved.
//

#import "AddressBookHelper.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>

@implementation AddressBookHelper

+ (void)addressBook:(AddressBookBlock)success denied:(NothingBlock)denied {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                success(addressBook);
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                denied();
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        success(addressBook);
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        denied();
    }

}

+ (void)phoneNumberForUser:(PFUser *)user success:(PhoneBlock)success error:(NothingBlock)error {
    // Fetch the address book
    [AddressBookHelper addressBook:^(ABAddressBookRef addressBook) {
        // Search for the person named "Appleseed" in the address book
        CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)user[@"name"]);
        
        // Display "Appleseed" information if found in the address book
        if ((people != nil) && (CFArrayGetCount(people) > 0))
        {
            ABRecordRef person = CFArrayGetValueAtIndex(people, 0);
            ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
            NSArray* phoneNumbers = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneNumberProperty);
            if (phoneNumbers.count > 0) {
                success(phoneNumbers[0]);
            } else {
                error();
            }
            CFRelease(phoneNumberProperty);
        }
        else
        {
            error();
        }
        CFRelease(addressBook);
        CFRelease(people);

    }denied:^{
        error();
    }];
    
}

@end
