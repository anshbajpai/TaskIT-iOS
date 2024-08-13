//
//  SignupViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 18/04/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore


class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    var authController: Auth?

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBOutlet weak var facebookSignInButton: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newColor = UIColor.black
        nameField.layer.borderColor = newColor.cgColor
        emailField.layer.borderColor = newColor.cgColor
        passwordField.layer.borderColor = newColor.cgColor
        
        nameField.layer.cornerRadius = 4
        nameField.layer.borderWidth = 0.3
        
        emailField.layer.cornerRadius = 4
        emailField.layer.borderWidth = 0.3
        
        passwordField.layer.cornerRadius = 4
        passwordField.layer.borderWidth = 0.3
        
        authController = Auth.auth()
        


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            // Just to transfer user to the correct screen according to the, sign in state, which can be either true or false
            handle = Auth.auth().addStateDidChangeListener{  auth, user in
                
                
                if let user = user {
                  // User is signed in. Show home screen
                    print("User")
                    print(user.uid)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "MyTabBarContoller")
                    //newViewController.modalPresentationStyle = .fullScreen
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(newViewController)


                } else {
                  // No User is signed in. Show user the login screen
                }

                
            }
        }

    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    //then you should implement the func named textFieldShouldReturn
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true);
        }
    
    @IBAction func googleBtnClicked(_ sender: Any) {
        
        userGoogleLogin()
    }
    
    
    @IBAction func facebookSignInBtnClicked(_ sender: Any) {
        self.loginButtonClicked()
    }
    
    func loginButtonClicked() {
            userFacebookLogin()
    }
    
    
    @IBAction func signUpBtnClicked(_ sender: Any) {

        Task {
            do {
                if(emailField.hasText && passwordField.hasText){
                    let authResult = try await authController?.createUser(withEmail: emailField.text!, password: passwordField.text!)
                    
                    // If signup is successfull, transferring the user to TabBarController screen
                    DispatchQueue.main.async {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MyTabBarContoller") as! MyTabBarController
                        
                        
                        
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(newViewController)
                    }
                }
                else {
                    self.displayMessage(title: "Error", message: "Invalid/Empty Input! Try Again")
                }
                
                print("User logged in")
            }
            catch {
                //self.displayMessage(title: "Error", message: "Login failed! Try Again")
                // Signup Failed
                print("User Signup failed")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: "Login failed! Try Again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    func googleSignIn(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {
            // ...
            print("ERROR")
              DispatchQueue.main.async {
                  let alertController = UIAlertController(title: "Error", message: "Login failed! Try Again", preferredStyle: .alert)
                  alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                  self.present(alertController, animated: true, completion: nil)
              }
            print(error)
            return
          }

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

            
          // ...
        }
    }
    
    
    @IBAction func loginChgBtnClicked(_ sender: Any) {
        //Going to loginViewController after change button has been clicked
        performSegue(withIdentifier: "signinSegue", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension UIViewController {
    // Extension function to display alert message
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    
    func userGoogleLogin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

          if let error = error {

              print("ERROR")
              DispatchQueue.main.async {
                  let alertController = UIAlertController(title: "Error", message: "Login failed! Try Again", preferredStyle: .alert)
                  alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                  self.present(alertController, animated: true, completion: nil)
              }
              print(error)
            // ...
            return
          }
            
        

          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.displayMessage(title: "Error", message: "Google Login failed! Try Again")
                }
            }
            
            print("User signed in")

          // ...
        }
    }
    
    func userFacebookLogin(){
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self, handler: { result, error in
            if error != nil {
                print("ERROR: Trying to get login results")
            } else if result?.isCancelled != nil {
                print("The token is \(result?.token?.tokenString ?? "")")
                if result?.token?.tokenString != nil {
                    print("Logged in")
                    let facebookCredentials = FacebookAuthProvider.credential(withAccessToken: (result?.token!.tokenString)!)
                    print(facebookCredentials)
                    
                    Auth.auth().signIn(with: facebookCredentials){ authResult, error in
                        if let error = error {
                            print("ERROR")
                            print(error)
                            print(error.localizedDescription)
                            self.displayMessage(title: "Error", message: "Facebook Login failed! Try Again")
                            
                            return
                        }
                    }
                    
                    print("User signed in")
                    
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC")
                    newViewController.modalPresentationStyle = .fullScreen
                    
                    let navViewController = MainNavigationController(rootViewController: newViewController)
                    
                    navViewController.modalPresentationStyle = .fullScreen

                            self.present(navViewController, animated: true, completion: nil)
                } else {
                    print("Cancelled")
                }
            }
        })
    }

}
