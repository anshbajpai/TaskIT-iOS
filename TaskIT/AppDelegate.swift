//
//  AppDelegate.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 11/04/22.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookCore
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {


    var window: UIWindow?
    var databaseController: DatabaseProtocol?
    
    static let CATEGORY_IDENTIFIER = "edu.moansh.TaskIT"
    
    var notificationsEnabled = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .notDetermined {
                
                notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    self.notificationsEnabled = granted
                    if granted {
                        self.setupNotifications()
                    }
                }
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                self.setupNotifications()
            }
        }
        
        databaseController = CoreDataController() 
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )

        
        return true
    }
    
    func setupNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
        let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
        let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
        let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .authenticationRequired, textInputButtonTitle: "Send", textInputPlaceholder: "Share your thoughts..")
        
        // Set up the category
        let appCategory = UNNotificationCategory(identifier: AppDelegate.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction, commentAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the category just created with the notification centre
        notificationCenter.setNotificationCategories([appCategory])
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Print some information to console saying we have recieved the notification
        // We could do some automatic processing here if we didnt want the user's response
        print("Notification triggered while app running")
        
        // By default iOS will silence a notification if the application is in the foreground. We can over-ride this with the following
        completionHandler([.banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == AppDelegate.CATEGORY_IDENTIFIER {
            switch response.actionIdentifier {
                case "accept":
                    print("accepted")
                case "decline":
                    print("declined")
                case "comment":
                    if let userResponse = response as? UNTextInputNotificationResponse {
                        print("Response: \(userResponse.userText)")
                        UserDefaults.standard.set(userResponse.userText, forKey: "response")
                    }
                default:
                    print("other")
            }
        }
        else {
            print("General notification")
        }
        completionHandler()
    }

}

