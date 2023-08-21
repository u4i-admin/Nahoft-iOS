//
//  ShareViewController.swift
//  Share
//
//  Created by Sadra Sadri on 4.08.2023.
//

import UIKit
import Social
import SwiftUI

class ShareViewController: UIViewController {
    @IBOutlet var container: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.text") {
                        attachment.loadItem(forTypeIdentifier: "public.text", options: nil, completionHandler: { text, _ in
                            DispatchQueue.main.sync {
                                let childView = UIHostingController(rootView: SwiftUIView(incoming_text: text as! String))
                                self.addChild(childView)
                                childView.view.frame = self.container.bounds
                                self.container.addSubview(childView.view)
                                childView.didMove(toParent: self)
                            }
                        })
                    } else {
                        self.close()
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            self.close()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
