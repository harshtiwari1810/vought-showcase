//
//  ViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        addSegmentedProgressBar()
        
    }
    
    @IBAction func storyBtnAction(_ sender: Any) {
        self.initCarouselView()
    }
    private func initCarouselView() {
        // Create a carousel item provider
        let carouselItemProvider = CarouselItemDataSourceProvider()
        
        // Create carouselViewController
        let carouselViewController = CarouselViewController(items: carouselItemProvider.items())
        
        // Add carousel view controller in container view
        //        carouselViewController.modalPresentationStyle = .fullScreen
        //        self.present(carouselViewController, animated: true,completion: nil)
        add(asChildViewController: carouselViewController, containerView: containerView)
    }
    
}

