//
//  GuidelinesViewController.swift
//  TeenaMathewFinalExam
//
//  Created by Student on 2020-04-20.
//  Copyright © 2020 Teena. All rights reserved.
//

import UIKit
import WebKit


class GuidelinesViewController: UIViewController , WKNavigationDelegate{

    @IBOutlet weak var labelInformation: UILabel!
    
    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

}
