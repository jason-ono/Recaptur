//
//  GuideCollectionViewController.swift
//  Captur
//
//  Created by Kotaro Ono on 2021/02/11.
//

import Foundation
import UIKit

class GuideCollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout{
    
    var indices = ["1", "2", "3", "4"]
    
    var currentVisibleIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.isPagingEnabled = true
        collectionView.isDirectionalLockEnabled = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return indices.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PageCell
        cell.cellDelegate = self
        let string = indices[indexPath.item]
        cell.idString = string
        cell.callCorrectMethod()
        return cell
        
//        if (indexPath.item == 0){
//            let string = indices[indexPath.item]
//            cell.idString = string
//            cell.callCorrectMethod()
//            return cell
//        }else{
//            let string = indices[indexPath.item]
//            cell.idString = string
//            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        for cell in collectionView.visibleCells {
//            let indexPath = collectionView.indexPath(for: cell)
//            print(indexPath!.item)
//        }
//    }
    
//    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        var visibleRect = CGRect()
//
//        visibleRect.origin = collectionView.contentOffset
//        visibleRect.size = collectionView.bounds.size
//
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//
//        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
//
//        currentVisibleIndexPath = indexPath
//        let cell = collectionView.cellForItem(at: indexPath) as! PageCell
//        cell.callCorrectMethod()
//    }
    
}

extension GuideCollectionViewController: PageCellDelegate{
    func dismissPressed() {
        self.dismiss(animated: true, completion: nil)
        
    }
}
