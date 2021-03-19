//
//  BuyViewController.swift
//  time:me
//
//  Created by Marlo Kessler on 13.07.19.
//  Copyright © 2019 Marlo Kessler. All rights reserved.
//

import UIKit
import StoreKit
import M13Checkbox
import SafariServices

protocol BuyViewDelegate {
    func didBuy(_ productID: String)
}

class BuyViewController: UIViewController, SKPaymentTransactionObserver, UITextViewDelegate, SKProductsRequestDelegate {
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var restoreAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var legalTextView: UITextView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var cannotBuyLabel: UILabel!
    @IBOutlet weak var buyActivityIndicator: UIActivityIndicatorView!
    
    var delegate: BuyViewDelegate?
    
    let defaults = UserDefaults.init(suiteName: "group.timeme.defaults")!
    
    let productID = "com.timeme.timeme.timeme_plus"
    
    var demoDaysLeft: Int?
    var legalStatementsAccepted = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SKPaymentQueue.canMakePayments() {
            
            cannotBuyLabel.isHidden = true
            
            let productRequest = SKProductsRequest(productIdentifiers: [productID])
            productRequest.delegate = self
            productRequest.start()
        } else {
            
            cannotBuyLabel.layer.shadowRadius = 5
            cannotBuyLabel.layer.shadowOffset = CGSize(width: 0, height: 1.0)
            cannotBuyLabel.layer.shadowOpacity = 0.2
            cannotBuyLabel.isHidden = false
        }
        
        let text = NSMutableAttributedString(string: NSLocalizedString("legal label text", comment: ""))
        let termsAndConditionsRange = NSRange(location: Int(NSLocalizedString("gtac location", comment: ""))!, length: Int(NSLocalizedString("gtac length", comment: ""))!)
        let privacyStatementRange = NSRange(location: Int(NSLocalizedString("privacy statement location", comment: ""))!, length: Int(NSLocalizedString("privacy statement length", comment: ""))!)
        
        var termsAndConditionsURL = ""
        var privacyStatementURL = ""
        
        switch NSLocale.current.languageCode {
        case "de":
            termsAndConditionsURL = "https://www.timeme.eu/inapp-agbs?lang=de"
            privacyStatementURL = "https://www.timeme.eu/inapp-datenschutzerklaerung?lang=de"
            
        case "en":
            termsAndConditionsURL = "https://www.timeme.eu/inapp-agbs?lang=en"
            privacyStatementURL = "https://www.timeme.eu/inapp-datenschutzerklaerung/?lang=en"
            
        default:
            termsAndConditionsURL = "https://www.timeme.eu/inapp-agbs?lang=en"
            privacyStatementURL = "https://www.timeme.eu/inapp-datenschutzerklaerung/?lang=en"
        }
        
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.shadowRadius = 5
        cancelButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cancelButton.layer.shadowOpacity = 0.2
        
        restoreButton.layer.cornerRadius = 5
        restoreButton.layer.shadowRadius = 5
        restoreButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        restoreButton.layer.shadowOpacity = 0.2
        
        restoreAcitivityIndicator.isHidden = true
        
        titleLabel.layer.shadowRadius = 5
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        titleLabel.layer.shadowOpacity = 0.2
        
        bodyLabel.layer.shadowRadius = 5
        bodyLabel.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        bodyLabel.layer.shadowOpacity = 0.2
        
        checkbox.secondaryTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        checkbox.tintColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        checkbox.boxLineWidth = 2
        
        legalTextView.delegate = self
        text.addAttribute(.link, value: termsAndConditionsURL, range: termsAndConditionsRange)
        text.addAttribute(.link, value: privacyStatementURL, range: privacyStatementRange)
        legalTextView.attributedText = text
        legalTextView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        buyActivityIndicator.isHidden = true
        
        buyButton.isHidden = true
        buyButton.layer.cornerRadius = 5
        buyButton.layer.shadowRadius = 5
        buyButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        buyButton.layer.shadowOpacity = 0.2
        
        SKPaymentQueue.default().add(self)
        
        if demoDaysLeft! > 0 {
            print("\(demoDaysLeft!) demodays left")
            cancelButton.isHidden = false
            
            bodyLabel.text = NSLocalizedString("buy view bodylabel demo first part", comment: "") + "\(demoDaysLeft!)" + NSLocalizedString("buy view bodylabel demo second part", comment: "")
        } else {
            print("No (\(demoDaysLeft!)) demodays left")
            bodyLabel.text = NSLocalizedString("buy view buy now", comment: "")
            cancelButton.isHidden = true
        }
    }
    
    
    
    //Gets the current product from the App Store
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if !response.products.isEmpty && response.products[0].productIdentifier == productID {
            
            let product = response.products[0]
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            buyButton.setTitle(formatter.string(from: product.price)!, for: .normal)
            buyButton.isHidden = false
        }
    }
    
    
    
    @IBAction func buy(_ sender: UIButton) {
        print("buy button pressed")
        if checkbox.checkState == .checked {
            let paymentRequest = SKMutablePayment()
            
            paymentRequest.productIdentifier = productID
//            let discount = SKPaymentDiscount(identifier: <#T##String#>, keyIdentifier: <#T##String#>, nonce: <#T##UUID#>, signature: <#T##String#>, timestamp: <#T##NSNumber#>)
//            paymentRequest.
//            paymentRequest.paymentDiscount = discount
            
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            
            checkbox.secondaryTintColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            legalTextView.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
    }
    
    
    
    //MARK: - Delegate functions
    //SKPaymentQueueObserverDelegate function
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Delegate function exec")
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case .purchasing, .deferred:
                print("purchasing or deffered")
                buyButton.isHidden = true
                buyActivityIndicator.isHidden = false
                
                
            case .purchased:
                print("purchased")
                buyActivityIndicator.isHidden = true
                buyButton.isHidden = true
                
                queue.finishTransaction(transaction)
                
                let action = UIAlertController(title: NSLocalizedString("welcome to tm+ title", comment: ""), message: NSLocalizedString("welcome to tm+ description", comment: ""), preferredStyle: .alert)
                
                let okay = UIAlertAction(title: NSLocalizedString("alright", comment: ""), style: .cancel) { (action) in
                    
                    
                    self.dismiss(animated: true) {
                        
                        self.delegate?.didBuy(self.productID)
                    }
                }
                action.addAction(okay)
                
                present(action, animated: true, completion: nil)
                
                
            case .restored:
                print("restored")
                restoreAcitivityIndicator.isHidden = true
                restoreButton.isHidden = false
                buyActivityIndicator.isHidden = true
                buyButton.isHidden = true
                
                queue.finishTransaction(transaction)
                
                let action = UIAlertController(title: NSLocalizedString("bought got restored title", comment: ""), message: nil, preferredStyle: .alert)
                
                let okay = UIAlertAction(title: NSLocalizedString("alright", comment: ""), style: .cancel) { (action) in
                    
                    self.delegate?.didBuy(self.productID)
                    self.dismiss(animated: true, completion: nil)
                }
                action.addAction(okay)
                
                present(action, animated: true, completion: nil)
                
                
            case .failed:
                print("failed")
                restoreAcitivityIndicator.isHidden = true
                restoreButton.isHidden = false
                buyActivityIndicator.isHidden = true
                buyButton.isHidden = false
                
                queue.finishTransaction(transaction)
                
                
            @unknown default:
                fatalError("Fatal Error due to unknown transactionState value in switch statement")
            }
        }
    }
    
    
    
    //MARK: - UITextViewDelegate function
    func textView(_ textView: UITextView, shouldInteractWith: URL, in: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        show(SFSafariViewController.init(url: shouldInteractWith), sender: self)
        
        return false
    }
    
    
    
    @IBAction func restore(_ sender: UIButton) {
        
        restoreButton.isHidden = true
        restoreAcitivityIndicator.isHidden = false
        print("Restore button pressed")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}
