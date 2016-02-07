//
//  DragNDropViewController.swift
//  DragNDrop
//
//  Created by Dan Fairbanks on 1/3/15.
//  Copyright (c) 2015 Dan Fairbanks. All rights reserved.
//

//  Modified by Govin Vatsan - 1/7/16
//  Added autoscroll for UITableView when dragging UITableViewCells
//  Code is adapted from HPReorderTableView - github.com/hpique/HPReorderTableView


import UIKit

class DragNDropViewController: UITableViewController {
    
    var itemsArray:[String] = {
        var tempArr = [String]()
        for var i = 1; i < 101; i++ {
            tempArr.append("Item \(i)")
        }
        return tempArr
    }()
    
    var longpress = UIGestureRecognizer()
    var scrollRate: CGFloat = 0.0 //rate of automatic scrolling when dragging a cell
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        tableView.addGestureRecognizer(longpress)
        
    }
    
    struct My {
        static var cellSnapshot : UIView? = nil
    }
    struct Path {
        static var initialIndexPath : NSIndexPath? = nil
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(locationInView)
        
        
        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                
                My.cellSnapshot  = snapshotOfCell(cell)
                var center = cell.center
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 1
                
                tableView.addSubview(My.cellSnapshot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    center.y = locationInView.y
                    
                    My.cellSnapshot!.center = center //set new cell center to location of user press
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05) //makes the selected row larger
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    }, completion: { (finished) -> Void in
                        if finished {
                            cell.hidden = true
                        }
                })
                
                //Matches scrolling to the refresh rate of the device
                let scrollDisplay = CADisplayLink(target: self, selector: "scrollTable")
                scrollDisplay.frameInterval = 1
                scrollDisplay.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
                
            }
        case UIGestureRecognizerState.Changed:
            getScrollRate(locationInView.y)         //gets the rate at how fast we should be scrolling
            var center = My.cellSnapshot!.center    //set center = to the current center of moving cell
            center.y = locationInView.y             //now set center y value to the new touched y value
            My.cellSnapshot!.center = center        //set dragging cell's center to the new cell
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                swap(&itemsArray[indexPath!.row], &itemsArray[Path.initialIndexPath!.row])
                tableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                Path.initialIndexPath = indexPath
            }
        default:
            scrollRate = 0
            gestureRecognizer.enabled = false
            gestureRecognizer.enabled = true        // http://stackoverflow.com/a/4167471/143378
            
            let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
            cell.hidden = false
            cell.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                My.cellSnapshot!.center = cell.center
                My.cellSnapshot!.transform = CGAffineTransformIdentity
                My.cellSnapshot!.alpha = 0.0
                cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
            })
            
        }
    }
    
    
    func snapshotOfCell(inputView: UIView) -> UIView {  //returns a UIView
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext() //takes a snapshot of the cell
        
        let cellSnapshot : UIView = UIImageView(image: image)
        
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.8
        
        return cellSnapshot
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = itemsArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    //MARK: Scroll When Dragging
    
    ///Calculates the rate at which the table should automatically scroll if dragging a cell around
    func getScrollRate (currentLocationY: CGFloat) {
        let scrollHeight: CGFloat = 80;
        let topScrollStart = tableView.contentOffset.y + scrollHeight
        let bottomScrollStart = tableView.contentOffset.y + tableView.bounds.height - scrollHeight
        
        if (currentLocationY <= topScrollStart) {
            scrollRate = (currentLocationY - topScrollStart)/scrollHeight
        }
        else if (currentLocationY >= bottomScrollStart) {
            scrollRate = (currentLocationY - bottomScrollStart)/scrollHeight
        }
        else {
            scrollRate = 0
        }
    }
    
    ///Moves the table up or down when dragging a cell to a new location
    func scrollTable() {
        
        let currentLocation = longpress.locationInView(tableView)
        let currentOffset = tableView.contentOffset;
        var newOffset = CGPointMake(currentOffset.x, currentOffset.y + scrollRate * 4);
        
        if (newOffset.y < -tableView.contentInset.top)  //so we can't scroll up further than the top/bottom limit of tableView
        {
            newOffset = currentOffset
        }
        else if (newOffset.y > (tableView.contentSize.height + tableView.contentInset.bottom) - tableView.frame.size.height)
        {
            newOffset = currentOffset
        }
        if newOffset != currentOffset && scrollRate != 0 {
            tableView.setContentOffset(newOffset, animated: false)  //WILL NOT WORK if animated = true
            My.cellSnapshot?.center.y = currentLocation.y
            
        }
    }
    
}
