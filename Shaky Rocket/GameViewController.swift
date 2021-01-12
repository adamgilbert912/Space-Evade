//
//  GameViewController.swift
//  Shaky Rocket
//
//  Created by macbook on 1/11/20.
//  Copyright © 2020 example. All rights reserved.
//add GadInterstitial

import UIKit
import StoreKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate, GADRewardedAdDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var interstitial: GADInterstitial!
    var rewardedAD: GADRewardedAd!
    var myProduct: SKProduct?
    
    var userRewarded: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-2203753281134636/6824172923")
            interstitial.load(GADRequest())
            interstitial.delegate = self
        
            rewardedAD = GADRewardedAd(adUnitID: "ca-app-pub-2203753281134636/4032683584")
            rewardedAD.load(GADRequest())
        
        userRewarded = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(showInterstitial), name: NSNotification.Name("showInterstitial"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchProducts), name: NSNotification.Name("fetchProducts"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tappedBuy), name: NSNotification.Name("tappedBuy"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showRewardedAd), name: NSNotification.Name("showRewardedAd"), object: nil)

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let mainMenu = MainMenu(size: CGSize(width: 667, height: 375), presentedFromGame: false, newRocket: false)
                // Set the scale mode to scale to fit the window
                mainMenu.scaleMode = .aspectFit
                
                // Present the scene
                view.presentScene(mainMenu)
            
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func showInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
            
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-2203753281134636/6824172923")
            interstitial.delegate = self
            interstitial.load(GADRequest())
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
            
            print("wasnt ready")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
    }
    
    //Rewarded Ad ---
    
    @objc func showRewardedAd() {
        if rewardedAD.isReady {
            rewardedAD.present(fromRootViewController: self, delegate: self)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
            
            print("wasnt ready")
        }
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        userRewarded = true
    }
    
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
    }
    
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if userRewarded {
            NotificationCenter.default.post(name: NSNotification.Name("setUserRewarded"), object: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
        }
        
        rewardedAD = GADRewardedAd(adUnitID: "ca-app-pub-2203753281134636/4032683584")
        rewardedAd.load(GADRequest())
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        NotificationCenter.default.post(name: NSNotification.Name("showStats"), object: nil)
        
        rewardedAD = GADRewardedAd(adUnitID: "ca-app-pub-2203753281134636/4032683584")
        rewardedAd.load(GADRequest())
    }
    
    //In app purchase ---
    
    @objc func tappedBuy() {
        guard let product = myProduct else {return}
        
        if SKPaymentQueue.canMakePayments() {
            print("working and can make payments")
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @objc func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.SpaceEvade.WheelSpin"])
        request.delegate = self
        request.start()
        print("products fetched")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("products being requested")
        
        if (response.products.isEmpty) {
            print("empty products")
        }

        if let product = response.products.first {
            print("products found")
            myProduct = product
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                
                NotificationCenter.default.post(name: NSNotification.Name("goodLeverStart"), object: nil)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            case .failed, .deferred:
                
                NotificationCenter.default.post(name: NSNotification.Name("badLeverStart"), object: nil)
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
                break
            }
        }
    }
}
