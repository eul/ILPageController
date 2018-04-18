//
//  ILPageController.swift
//  ILPageController
//
//  Created by TS.MAC on 4/16/18.
//  Copyright © 2018 eul. All rights reserved.
//

import Foundation
import UIKit

enum PageControllsState {
    case scrollToTop
    case scrollToBottom
    case undefined
}

public class ILPageController :NSObject, UIScrollViewDelegate {

    public var currentPhotoIndex = 0
    public var didChangeCurrentPage :((Int) -> Void)?

    private var itemsCount      :Int
    private weak var parentView :UIView!
    private weak var scrollView :UIScrollView!
    private var pageControlls   :NSPointerArray!
    private var styler          :ILPageControllerStylerPt

    private var pageControllsState :PageControllsState = .undefined

    private var isFirstPageControllVisible = true

    private var indexes     :(overallIndex :Int, pageIndex :Int) = (0,0)
    private var nextIndexes :(overallIndex :Int, pageIndex :Int) = (0,0)

    private var setupDone = false

    /* Initializer
       scrollView: scrollView to handle page changing and scrolling
       parentView: View to add UIPageControls
       pageCount: count of the pages
     */
    init(scrollView  :UIScrollView,
         parentView  :UIView?,
         pageCount   :Int,
         styler      :ILPageControllerStylerPt = ILPageControllerStyler()) {

        self.scrollView      = scrollView
        self.parentView      = parentView ?? scrollView
        self.itemsCount      = pageCount
        self.styler          = styler

        super.init()

        scrollView.delegate = self

        addPageControlsTo(view: scrollView.superview!)
    }

    private func addPageControlsTo(view :UIView) {

        let pageControll0 = UIPageControl()
        let pageControll1 = UIPageControl()

        view.addSubview(pageControll0)
        view.addSubview(pageControll1)

        pageControll0.currentPageIndicatorTintColor = .black
        pageControll1.currentPageIndicatorTintColor = .black
        pageControll0.pageIndicatorTintColor = .white
        pageControll1.pageIndicatorTintColor = .white

        pageControlls   = NSPointerArray.weakObjects()
        pageControlls.addPointer(Unmanaged.passUnretained(pageControll0).toOpaque())
        pageControlls.addPointer(Unmanaged.passUnretained(pageControll1).toOpaque())

        pageControlls.allObjects.forEach({ ($0 as! UIPageControl).numberOfPages = styler.maxVisibleDots})
    }

    public func reload() {

        if !setupDone { return }

        indexes = (0, 0)
        nextIndexes = indexes

        updatePageControllsWith(isFirstVisible: true)
        applyPageControlls(newState: .undefined)
        applyPageControlls(newState: .scrollToTop)

        didChangeCurrentPage?(currentPhotoIndex)
    }

    private var visiblePageControll :UIPageControl {
        get {
            return pageControlls.allObjects[isFirstPageControllVisible ? 0 : 1] as! UIPageControl
        }
    }

    private var invisiblePageControll :UIPageControl {
        get {
            return pageControlls.allObjects[isFirstPageControllVisible ? 1 : 0] as! UIPageControl
        }
    }

    public func setup() {

        pageControlls.allObjects.forEach({ ($0 as! UIPageControl).transform = CGAffineTransform.identity.rotated(by: .pi / 2.0)})

        updatePageControllsWith(isFirstVisible: true)

        setupDone = true
    }

    public func updatePageControllsWith(isFirstVisible :Bool) {

        isFirstPageControllVisible = isFirstVisible

        if nextIndexes.pageIndex == styler.maxVisibleDots - 1 {

            applyCurrent(indexes: (overallIndex: nextIndexes.overallIndex, pageIndex: 1))
            invisiblePageControll.currentPage = 1

            applyPageControlls(newState: .undefined)

        } else if nextIndexes.pageIndex == 0 && nextIndexes.overallIndex != 0 {

            applyCurrent(indexes: (overallIndex: nextIndexes.overallIndex, pageIndex: styler.maxVisibleDots - 2))
            invisiblePageControll.currentPage = styler.maxVisibleDots - 2

            applyPageControlls(newState: .undefined)

        } else {

            applyCurrent(indexes: (overallIndex: nextIndexes.overallIndex, pageIndex: nextIndexes.pageIndex))
        }

        visiblePageControll.alpha   = 1
        invisiblePageControll.alpha = 0

        if pageControllsState == .undefined {

            applyPageControlls(newState: .scrollToTop)
        }

        parentView.bringSubview(toFront: visiblePageControll)
        parentView.bringSubview(toFront: invisiblePageControll)
    }

    private func applyCurrent(indexes :(overallIndex :Int, pageIndex :Int)) {

        self.indexes = indexes

        if currentPhotoIndex != indexes.overallIndex {

            currentPhotoIndex = indexes.overallIndex
            didChangeCurrentPage?(currentPhotoIndex)
        }

        visiblePageControll.currentPage = self.indexes.pageIndex
    }

    public func scrollToIndex(index :Int) {

        var p = scrollView.contentOffset

        p.y = scrollView.bounds.height * CGFloat(index)

        scrollView.setContentOffset(p, animated: false)

        indexes.overallIndex = index

        if itemsCount <= styler.maxVisibleDots || (index < (styler.maxVisibleDots - 1)) {

            indexes.pageIndex = index
        }
        else if itemsCount > styler.maxVisibleDots {

            indexes.pageIndex = (index % (styler.maxVisibleDots - 1)) + 1
        }

        visiblePageControll.currentPage = indexes.pageIndex

        applyPageControlls(newState: .undefined)
        applyPageControlls(newState: (indexes.pageIndex - styler.maxVisibleDots) < 2 ? .scrollToTop : .scrollToBottom)

        nextIndexes = indexes
    }

    //Tested magic nambers
    private let pageControllWidth    :CGFloat = 71.0
    private var pageControllsOffset  :CGFloat = 23.0
    private var startDraggingY       :CGFloat = 0
    private let minDeltaToChangePage = CGFloat(70)

    private func applyPageControlls(newState :PageControllsState) {

        if pageControllsState == newState {

            return
        }

        if pageControllsState == .undefined {

            let currentPageItemsCount = itemsCount - indexes.overallIndex + indexes.pageIndex

            visiblePageControll.numberOfPages = (currentPageItemsCount < styler.maxVisibleDots)
                ? currentPageItemsCount
                : (itemsCount >= styler.maxVisibleDots ? styler.maxVisibleDots : itemsCount)

        }

        visiblePageControll.transform.ty   = 0
        invisiblePageControll.transform.ty = 0

        let size = visiblePageControll.size(forNumberOfPages: visiblePageControll.numberOfPages)

        var rect = CGRect(x: parentView.bounds.width - styler.pageControllTrailing, y: styler.pageControllY,
                      width: pageControllWidth,
                     height: size.width)

        visiblePageControll.frame = rect

        if .scrollToTop == newState {

            rect.origin.y = rect.maxY - pageControllsOffset

            if itemsCount < styler.maxVisibleDots {

                visiblePageControll.numberOfPages = itemsCount

            }else {

                let nextPageItemsCount = itemsCount - indexes.overallIndex - (styler.maxVisibleDots - indexes.pageIndex)

                invisiblePageControll.numberOfPages = nextPageItemsCount > styler.maxVisibleDots ? styler.maxVisibleDots : (nextPageItemsCount + 2)

                invisiblePageControll.currentPage = 1

                rect.size.height = invisiblePageControll.size(forNumberOfPages: invisiblePageControll.numberOfPages).width
            }
        }

        if .scrollToBottom == newState {

            invisiblePageControll.numberOfPages = styler.maxVisibleDots

            rect.size.height = invisiblePageControll.size(forNumberOfPages: invisiblePageControll.numberOfPages).width
            rect.origin.y    = rect.minY - rect.size.height + pageControllsOffset

            invisiblePageControll.currentPage = styler.maxVisibleDots - 2

        }

        invisiblePageControll.frame = rect

        pageControllsState = newState
    }

    private func needPageControllsChangeWith(scrollToTop :Bool) -> Bool {

        let welfiesLeft = itemsCount - indexes.overallIndex - 1

        let bottomBorderReached = (indexes.pageIndex == styler.maxVisibleDots - 2) && welfiesLeft > 1 && (scrollToTop)
        let topBorderReached    = !scrollToTop && (indexes.pageIndex == 1) && (indexes.overallIndex >= styler.maxVisibleDots - 1)

        return bottomBorderReached || topBorderReached
    }

    //MARK:- UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        startDraggingY = scrollView.contentOffset.y
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        scrollView.isScrollEnabled = false

        let deltaY = targetContentOffset.pointee.y - startDraggingY

        let isDraggingToTop = deltaY > 0

        nextIndexes = indexes

        if let isIncrement = (abs(deltaY) > minDeltaToChangePage) ? (isDraggingToTop ? true : false) : nil {

            nextIndexes.overallIndex = isIncrement ? nextIndexes.overallIndex + 1 : nextIndexes.overallIndex - 1
            nextIndexes.pageIndex    = isIncrement ? nextIndexes.pageIndex    + 1 : nextIndexes.pageIndex    - 1
        }

        targetContentOffset.pointee.y = CGFloat(nextIndexes.overallIndex) * parentView.bounds.height
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        scrollView.isScrollEnabled = true
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let deltaY = scrollView.contentOffset.y - startDraggingY

        let isScrollToTop = deltaY > 0

        let percent = deltaY / scrollView.bounds.height

        if abs(percent) < 0.98 && needPageControllsChangeWith(scrollToTop: isScrollToTop) {

            let size = visiblePageControll.size(forNumberOfPages: styler.maxVisibleDots)

            let pageControllHeight = size.width - pageControllsOffset

            visiblePageControll.transform.ty   =  pageControllHeight * -percent
            invisiblePageControll.transform.ty = pageControllHeight  * -percent

            if isScrollToTop {

                applyPageControlls(newState: .scrollToTop)

                visiblePageControll.alpha   = 1.0 - percent
                invisiblePageControll.alpha = 0.0 + percent

            } else {

                applyPageControlls(newState: .scrollToBottom)

                visiblePageControll.alpha   = 1.0 + percent
                invisiblePageControll.alpha = 0.0 - percent
            }
        }

        if !scrollView.isScrollEnabled && abs(percent) >= 0.98 {


            if needPageControllsChangeWith(scrollToTop: isScrollToTop) {

                updatePageControllsWith(isFirstVisible: !isFirstPageControllVisible)

            }else {

                applyCurrent(indexes: nextIndexes)
            }

            scrollView.isScrollEnabled = true
        }
    }
}
