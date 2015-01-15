//
//  DragNDropViewController.swift
//  DragNDrop
//
//  Created by Dan Fairbanks on 1/3/15.
//  Copyright (c) 2015 Dan Fairbanks. All rights reserved.
//

import UIKit

class DragNDropViewController: UITableViewController {
    
    var itemsArray : [String]
    
    required init(coder aDecoder: NSCoder) {
        itemsArray = [String]()
        
        let item1 = "Bananas"
        let item2 = "Oranges"
        let item3 = "Kale"
        let item4 = "Milk"
        let item5 = "Yogurt"
        let item6 = "Crackers"
        let item7 = "Cheese"
        let item8 = "Carrots"
        let item9 = "Ice Cream"
        let item10 = "Olive Oil"
        
        itemsArray.append(item1)
        itemsArray.append(item2)
        itemsArray.append(item3)
        itemsArray.append(item4)
        itemsArray.append(item5)
        itemsArray.append(item6)
        itemsArray.append(item7)
        itemsArray.append(item8)
        itemsArray.append(item9)
        itemsArray.append(item10)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = itemsArray[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

}
