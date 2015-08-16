//
//  Settings.swift
//  LazyCalendar
//
//  Created by Ying Tao on 8/11/15.
//  Copyright (c) 2015 Kim. All rights reserved.
//

import UIKit
import CoreData
import AddressBook
import CoreLocation

extension NSObject {
    // MARK: - Methods related to checking permissions.
    
    /**
        Returns a `Bool` indicating whether or not notifications are enabled.
    
        Notifications are enabled if alerts, badges, and sound are enabled.
    */
    func notificationsEnabled() -> Bool {
        let notificationTypes = UIApplication.sharedApplication().currentUserNotificationSettings().types
        if notificationTypes.rawValue & UIUserNotificationType.Alert.rawValue != 0 && notificationTypes.rawValue & UIUserNotificationType.Badge.rawValue != 0 && notificationTypes.rawValue & UIUserNotificationType.Sound.rawValue != 0 {
            return true
        }
        return false
    }
    
    // MARK: - Methods related to user location access.
    
    /**
        Returns a `Bool` indicating if the user location is accessible.
    
        :returns: A `Bool` indicating whether or not the user location is accessible.
    */
    func locationAccessible() -> Bool {
        return CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse || CLLocationManager.authorizationStatus() == .AuthorizedAlways
    }
    
    // MARK: - Methods related to address book access.
    
    /**
        Returns a `Bool` indicating whether or not address book is accessible.
    
        :returns: A `Bool` indicating whether or not address book is accessible.
    */
    func addressBookAccessible() -> Bool {
        return ABAddressBookGetAuthorizationStatus() == .Authorized
    }
}

extension UIViewController {
    // MARK: - Methods related to creating alerts for specific permissions.
    
    /**
        Displays an alert indicating that notifications are disabled.
    
        This occurs when the user attempts to press the alarm switch or select the alarm cell when they have notifications disabled.
    */
    func displayNotificationsDisabledAlert() {
        presentPermissionAlertController("Notifications Disabled", "You must give permission to send notifications to use this feature.")
    }

    /**
        Alerts the user that access to contacts is denied or restricted and requests a permissions change by going to settings.
    
        This occurs when the user is first prompted for access in `displayContactsAccessRequest` and denies access or in future attempts to press the contacts cell when permission is denied or restricted.
    */
    func displayAddressBookInaccessibleAlert() {
        presentPermissionAlertController("Cannot Access Contacts", "You must give permission to access contacts to use this feature.")
    }
    
    /**
        Alerts the user that access to user location is denied or restricted and requests a permissions change by going to settings.
    */
    func displayLocationInaccessibleAlert() {
        presentPermissionAlertController("Cannot Access User Location", "You must give permission to access locations to use this feature.")
    }
    
    // MARK: - Methods for presenting alerts.
    
    /**
        Presents a `UIAlertController` with a given title and message and options to change settings or dismiss the alert.
    
        This method is used to present an alert controller when the user tries to access a feature that requires a denied permission. It states that permissions to the feature is denied and that settings must be changed in order for said feature to be used. On pressing the "Settings" option, settings will be opened. On pressing the "OK" option, the alert will be dismissed.
    */
    func presentPermissionAlertController(title: String?, _ message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let settingsAlertAction = UIAlertAction(title: "Settings", style: .Default, handler: {
            action in
            self.openSettings()
        })
        let okAlertAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(settingsAlertAction)
        alertController.addAction(okAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
        Opens the settings menu.
    
        This is called when requested access for user information is denied and permissions should be changed.
    */
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
}