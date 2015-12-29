//
//  ModelController.swift
//  AppConnectSample
//
//  Created by Steve Roy on 2015-12-16.
//  Copyright © 2015 Medidata Solutions. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    private var fields: [MDField] = []

    var form: MDForm! {
        didSet {
            self.fields = form.fields as! [MDField]
        }
    }

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> UIViewController? {
        // Return the data view controller for the given index.
        guard self.fields.count > 0 || index <= self.fields.count else {
            return nil
        }
        
        if index == self.fields.count {
            let reviewViewController = storyboard.instantiateViewControllerWithIdentifier("ReviewViewController") as! ReviewViewController
            reviewViewController.form = form
            return reviewViewController
        }
        
        let field = fields[index]

        // Create a new view controller and pass suitable data.
        let fieldViewController = storyboard.instantiateViewControllerWithIdentifier("FieldViewController") as! FieldViewController
        fieldViewController.field = field
        return fieldViewController
    }

    func indexOfViewController(viewController: UIViewController) -> Int {
        if viewController.isMemberOfClass(ReviewViewController) {
            return fields.count
        }
        return indexOfField((viewController as! FieldViewController).field.objectID)
    }
    
    func indexOfField(fieldID: Int64) -> Int {
        for (index, f) in fields.enumerate() {
            if f.objectID == fieldID {
                return index
            }
        }
        return NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        
        guard index != 0 && index != NSNotFound else {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        
        guard index < self.fields.count else {
            return nil
        }
        
        // Don't allow progression to the next field unless the current
        // field has been properly answered
        let field = fields[index]
        guard field.responseProblem == MDFieldProblem.None else {
            return nil
        }
        
        index++
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

