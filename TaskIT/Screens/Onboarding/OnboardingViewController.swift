//
//  OnboardingViewController.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 12/04/22.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    var pages: [OnboardingPage] = []
    var currentPage = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = userDefaults.bool(forKey: "onBoarding")
        if value {
            performSegue(withIdentifier: "registerSegue", sender: nil)
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        getStartedButton.isHidden = true
        
        // This is data, which needs to be shown in oboarding screens
        pages = [
            OnboardingPage(heading: "Write down \n all your Tasks !!",
                           description: "Get notified and sort your tasks \n based on priortity.", pageImage: UIImage(named: "Onboarding1")!),
            OnboardingPage(heading: "Your tasks \n offline & online",
                           description: "Log in/Sign Up using google/facebook to \n manage your tasks across devices.", pageImage: UIImage(named: "Onboarding2")!),
            OnboardingPage(heading: "Make a checklist !",
                           description: "Create a checklist, for all the tasks \n to do and get notified about them.", pageImage: UIImage(named: "Onboarding3")!),
            
        ]
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        // Setting up the logic, so appropriate action is performed
        if currentPage != pages.count - 1{
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageController.currentPage = currentPage
            
            if currentPage == pages.count - 1 {
                nextButton.isHidden = true
                skipButton.isHidden = true
                getStartedButton.isHidden = false
            }
            else {
                nextButton.isHidden = false
                skipButton.isHidden = false
                getStartedButton.isHidden = true
            }
        }
        
    }
    
    
    @IBAction func getStartedBtnClicked(_ sender: Any) {
        // Changing user view to SignUpViewController
        userDefaults.set(true, forKey: "onBoarding")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "SignupVC") as! SignupViewController
        newViewController.modalPresentationStyle = .fullScreen
        
        let navViewController = UINavigationController(rootViewController: newViewController)
        
        navViewController.modalPresentationStyle = .fullScreen

                self.present(navViewController, animated: true, completion: nil)
//        performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    @IBAction func skipBtnClicked(_ sender: Any) {
        // Skip button - to jump straight to the last page and get started
        currentPage = pages.count - 1
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageController.currentPage = currentPage
        
        if currentPage == pages.count - 1 {
            nextButton.isHidden = true
            skipButton.isHidden = true
            getStartedButton.isHidden = false
        }
        else {
            nextButton.isHidden = false
            skipButton.isHidden = false
            getStartedButton.isHidden = true
        }
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

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Populating the cell, with content and ui as needed
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell" ,for: indexPath) as! OnboardingCollectionViewCell
        cell.initialize(pages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Setting up the size of collection view
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // This basically handles the logic to change the indicator at the bottom of onboarding , so that user knows how the overall layout of onboarding is setup
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageController.currentPage = currentPage
        
        if currentPage == pages.count - 1 {
            nextButton.isHidden = true
            skipButton.isHidden = true
            getStartedButton.isHidden = false
        }
        else {
            nextButton.isHidden = false
            skipButton.isHidden = false
            getStartedButton.isHidden = true
        }
    }
    
}
