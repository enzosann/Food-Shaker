//
//  DragNDropViewController.swift
//  KitchenDelice
//
//  Created by Vincenzo Sannino on 07/03/2019.
//  Copyright © 2019 Vincenzo Sannino. All rights reserved.
//

import UIKit
import AVFoundation

class DragNDropViewController: UIViewController {
    //MARK: Private Properties
    //Data Source for CollectionView-1
    private var items1 = ["carrots", "spaghetti", "pasta", "tomato", "eggs", "meat", "milk", "garlic" ]

    //Data Source for CollectionView-2
    private var items2 = [String]()
    
    //MARK: Outlets
    @IBOutlet weak var ingredientCollection: UICollectionView!
    @IBOutlet weak var tableCollection: UICollectionView!
    @IBOutlet weak var imgForniture: UIImageView!
    @IBOutlet weak var viewForniture: UIView!

    
    @IBOutlet var modalView: UIView!
    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch( sender: )))
        viewForniture.addGestureRecognizer(pinch)
        
        //CollectionView-1 drag and drop configuration
        self.ingredientCollection.dragInteractionEnabled = true
        self.ingredientCollection.dragDelegate = self
        self.ingredientCollection.dropDelegate = self

        //CollectionView-2 drag and drop configuration
        self.tableCollection.dragInteractionEnabled = true
        self.tableCollection.dropDelegate = self
        self.tableCollection.dragDelegate = self
        self.tableCollection.reorderingCadence = .fast //default value - .immediate
        
        let layout = ingredientCollection.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 30
        ingredientCollection.collectionViewLayout = layout
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer){
        guard sender.view != nil else{return}
        
        if sender.state == .began || sender.state == .changed {
            imgForniture.image = UIImage.init(named: "openForniture")
            ingredientCollection.isHidden = false
            ingredientCollection.isUserInteractionEnabled = true
            ingredientCollection.backgroundColor = UIColor.clear
        }
    }
    

    //MARK: Private Methods
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                if collectionView === self.tableCollection
                {
                    self.items2.remove(at: sourceIndexPath.row)
                    self.items2.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                }
                else
                {
                    self.items1.remove(at: sourceIndexPath.row)
                    self.items1.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                }
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated()
            {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                if collectionView === self.tableCollection
                {
                    self.items2.insert(item.dragItem.localObject as! String, at: indexPath.row)
                }
                else
                {
                    self.items1.insert(item.dragItem.localObject as! String, at: indexPath.row)
                }
                indexPaths.append(indexPath)
            }
            collectionView.insertItems(at: indexPaths)
        })
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
//                override func of motion on Ended movement
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//                select exact case of use: motionShake
        if motion == .motionShake{
            if tableCollection.numberOfItems(inSection: 0) >= 2 {
//                add vibration if there are more than 2 ingredients
                UIDevice.vibrate()
//                add subview (modalView) and initialize the frame origin
                self.view.addSubview(modalView)
                modalView.frame.origin.y = 46
                modalView.frame.origin.x = 0
                }
    }
}

}
// MARK: - UICollectionViewDataSource Methods
extension DragNDropViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collectionView == self.ingredientCollection ? self.items1.count : self.items2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.ingredientCollection
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! DragNDropCollectionViewCell
            cell.customImageView?.image = UIImage(named: self.items1[indexPath.row])
            cell.customLabel.text = self.items1[indexPath.row].capitalized
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! DragNDropCollectionViewCell
            cell.customImageView?.image = UIImage(named: self.items2[indexPath.row])
//            cell.customLabel.text = self.items2[indexPath.row].capitalized
            return cell
        }
        
    }
}

// MARK: - UICollectionViewDragDelegate Methods
extension DragNDropViewController : UICollectionViewDragDelegate
{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let item = collectionView == ingredientCollection ? self.items1[indexPath.row] : self.items2[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        let item = collectionView == ingredientCollection ? self.items1[indexPath.row] : self.items2[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
    {
        if collectionView == ingredientCollection
        {
            let previewParameters = UIDragPreviewParameters()
            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 60, height: 60))
            previewParameters.backgroundColor = UIColor.clear
            return previewParameters
        }
        return nil
    }
}

// MARK: - UICollectionViewDropDelegate Methods
extension DragNDropViewController : UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if collectionView === self.ingredientCollection
        {
            if collectionView.hasActiveDrag
            {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .forbidden)
            }
        }
        else
        {
            if collectionView.hasActiveDrag
            {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath
        {
            destinationIndexPath = indexPath
        }
        else
        {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation
        {
        case .move:
            self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            break
            
        case .copy:
            self.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            
        default:
            return
        }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}


@IBDesignable
class RoundUIView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
