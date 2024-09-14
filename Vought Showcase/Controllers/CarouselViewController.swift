//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit


final class CarouselViewController: UIViewController {
    
    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    /// Carousel control with page indicator
    @IBOutlet private weak var carouselControl: UIPageControl!
    
    
    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    private var segmentedProgressBar: SegmentedProgressBar!
    
    /// Carousel items
    private var items: [CarouselItem] = []
    
    /// Current item index
    private var currentItemIndex: Int = 0
    private var currentController: UIViewController?
    
    /// Initializer
    /// - Parameter items: Carousel items
    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSegmentedProgressBar()
    }
    
    private func initSegmentedProgressBar() {
        let progressBarWidth: CGFloat = view.bounds.width - 20
        
        let progressBarX: CGFloat = (containerView.bounds.width - progressBarWidth) / 2
        
        segmentedProgressBar = SegmentedProgressBar(numberOfSegments: items.count)
        segmentedProgressBar.delegate = self
        segmentedProgressBar.frame = CGRect(x: progressBarX, y: 50, width: progressBarWidth, height: 4)
        segmentedProgressBar.topColor = UIColor.white
        segmentedProgressBar.bottomColor = UIColor.gray.withAlphaComponent(0.5)
        containerView.addSubview(segmentedProgressBar)
        
        self.replaceController(with: getController(at: currentItemIndex))
        self.setupImageViewTapGestures()
        segmentedProgressBar.isPaused = false
        segmentedProgressBar.startAnimation()
    }
    
    
    private func replaceController(with newController: UIViewController) {
        // Remove the current view controller if it exists
        if let currentController = currentController {
            currentController.willMove(toParent: nil)
            currentController.view.removeFromSuperview()
            currentController.removeFromParent()
        }
        
        // Add the new view controller
        addChild(newController)
        newController.view.frame = containerView.bounds
        containerView.addSubview(newController.view)
        containerView.bringSubviewToFront(segmentedProgressBar)
        newController.didMove(toParent: self)
        
        // Update the reference to the current view controller
        currentController = newController
    }
    
    
    
    /// Get controller at index
    /// - Parameter index: Index of the controller
    /// - Returns: UIViewController
    private func getController(at index: Int) -> UIViewController {
        print(index)
        return items[index].getController()
    }
    
    private func setupImageViewTapGestures() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        swipeDown.direction = .down
        containerView.addGestureRecognizer(swipeDown)
        containerView.addGestureRecognizer(panGesture)
        containerView.addGestureRecognizer(tap)
        
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let width = gesture.view?.bounds.width ?? 0
        
        if location.x < width / 2 {
            // Handle left tap
            segmentedProgressBar?.rewind()
        } else {
            // Handle right tap
            segmentedProgressBar?.skip()
        }
    }
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .down:
            DispatchQueue.main.async{
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        default:
            break
        }
    }
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view)
        
        switch gesture.state {
        case .changed:
            // Update the position of the view controller as the user drags
            let newY = max(translation.y, 0) // Prevent dragging above the original position
            self.view.transform = CGAffineTransform(translationX: 0, y: newY)
            
        case .ended:
            // Check if the gesture velocity indicates a downwards swipe
            if velocity.y > 1000 || translation.y > self.view.bounds.height / 2 {
                // Dismiss the view controller
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
                }, completion: { _ in
                    self.willMove(toParent: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                })
            } else {
                // Snap back to the original position
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
            
        default:
            break
        }
    }
    
    
}


extension CarouselViewController: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        // Update the carousel to show the page that corresponds to the current segment
        
        let controller = getController(at: index)
        
        replaceController(with: controller)
        
        currentItemIndex = index
    }
    
    func segmentedProgressBarFinished() {
        segmentedProgressBar.isPaused = true
    }
}
