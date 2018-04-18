//
//  ViewController.swift
//  ILPageController
//
//  Created by TS.MAC on 4/16/18.
//  Copyright © 2018 eul. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var collectionView: UICollectionView!

    private var pageController :ILPageController!

    private let itemsCount = 10

    override func viewDidLoad() {

        super.viewDidLoad()

        pageController = ILPageController(scrollView: collectionView,
                                          parentView: view,
                                           pageCount: itemsCount)

        pageController.didChangeCurrentPage = {

            print("ILPageController didChangeCurrentPage \($0)")
        }

        pageController.setup()
        pageController.reload()
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        collectionView.collectionViewLayout.invalidateLayout()
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 10
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:CollectionCellView.self), for: indexPath) as! CollectionCellView

        cell.textLabel.text = "Cell \(indexPath.row)"

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.bounds.width, height: 645)
    }
}

