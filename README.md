Hakuba
===========

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/nghialv/Hakuba.svg?style=flat
)](https://github.com/nghialv/Hakuba/issues?state=open)

I want to slim down my view controllers.

I want to manage tableview without the code of `UITableViewDelegate` and `UITableViewDataSource`.

That is why I created `Hakuba`.

( **Hakuba** is one of the most famous ski resorts in Japan. )

Features
-----
* Don't have to write the code for `UITableViewDelegate` and `UITableViewDataSource` protocols
* Easy to manage your sections and cells (append/reset/insert/remove/update)
* Support dynamic cell height from **ios7**
* Don't have to worry about cell identifier
* Handling cell selection by trailing closure
* Easy to implement header/footer view (floating callback)
* Support for creating cells from Nibs or Storyboards
* Method chaining
* Subscript
* Support loadmore closure
* Complete example

##### Quick example

``` swift
	// viewController swift file
	
	hakuba = Hakuba(tableView: tableView)
	
	let cellmodel = YourCellModel(title: "Title", des: "description") {
		println("Did select cell with title = \(title)")
	}
	
	hakuba[2].append(cellmodel)		// append a new cell model in datasource
			 .slide(.Fade)			// show the cell of your cell model in the table view
	
	hakuba[1].remove(1...3)
			 .slide(.Right)
```
``` swift
	// your cell swift file
	
	class YourCellModel : MYCellModel {
		let title: String
		let des: String
		
		init(title: String, des: String, selectionHandler: MYSelectionHandler) {
			self.title = title
			self.des = des
			super.init(YourCell.self, selectionHandler: selectionHandler)
		}
	}
	

	class YourCell : MYTableViewCell {
		@IBOutlet weak var titleLabel: UILabel!
    
		override func configureCell(data: MYCellModel) {
			super.configureCell(data)
			if let cellmodel = data as? YourCellModel {
				titleLabel.text = cellmodel.title
        	}
      	}
	}
```

Usage
-----

 * Initilization

``` swift
	private var hakuba = Hakuba(tableView: tableView)   
```

* Section handling

``` swift
	let section = hakuba[secIndex]	// retrieve a section or create a new section if it doesn't already exist

	// inserting
	hakuba.insert(section, atIndex: 1)
		  .slide()
	
	// removing
	hakuba.remove(index)
	   	  .slide(.Left)
	
	hakuba.removeAll()
	   	  .slide()
	   	  
	// handing section index by enum
	enum Section : Int, MYSectionIndex {
		case Top = 0
		case Center
		case Bottom
		
		var intValue: Int {
			return self.rawValue
    	}
	}
	let topSection = hakuba[Section.Top]
```

* Cell handling

``` swift
	// 1. appending
	hakuba[0].append(cellmodel)				// append a cellmodel
		     .slide(.Fade)					// and slide with `Fade` animation

	hakuba[1].append(cellmodels)			// append a list of cellmodes
		  	.slide(.Left)					
	
	// by using section
	let section = hakuba[Section.Top]
	section.append(cellmodel)
		   .slide()


	// 2. inserting
	section.insert(cellmodels, atIndex: 1)
		   .slide(.Middle)
	
	
	// 3. reseting
	section.reset(cellmodels)				// replace current data in section by the new data
		   .slide()
	section.reset()							// or remove all data in section
		   .slide()
		   

	// 4. removing
	section.remove(1)
		   .slide(.Right)
	section.remove(2...5)
		   .slide()
	section.removeLast()
	       .slide()
```


``` swift
	// updating cell data
	let section = hakuba[Section.Top]
	section[1].property = newData
	section[1].slide()		
```


``` swift
	section.sort().slide()
	section.shuffle().slide()
	section.map
	section.filter
	section.reduce
	section.mapFilter
	section.each

	section.first
	section.last
	section[1]
	section.count
```


* Creating cell model

``` swift
	// create a cell model
	let cellmodel = MYCellModel(cellClass: YourCell.self, userData: celldata) {
		println("Did select")
	}
	
	// create a list of cell models from api results
	let items = [...] // or your data from API

    let cellmodels = items.map { item -> MYCellModel in
        return MYCellModel(cellClass: YourCell.self, userData: item) {
            println("Did select cell")
        }
    }
```

* Register cell, header, footer

``` swift
	hakuba.registerCellNib(CellClassName)
	hakuba.registerCellClass(CellClassName)
	hakuba.registerHeaderFooterNib(HeaderOrFooterClassName)
	hakuba.registerHeaderFooterClass(HeaderOrFooterClassName)
	
	// register a list of cells by using variadic parameters
	hakuba.registerCellNib(CellClass1.self, CellClass2.self, ..., CellClassN.self)
```

* Section header/footer

``` swift
	let header = MYHeaderFooterViewModel(viewClass: CustomHeaderView.self, userData: yourData) {
		println("Did select header view")
	}
	hakuba[Section.Top].header = header
	
	// hide header in section 1
	hakuba[Section.Center].header?.enabled = false
```

* Loadmore

``` swift
	hakuba.loadmoreEnabled = true
	hakuba.loadmoreHandler = {
		// request api
		// append new data
	}
```

* Commit editing 

``` swift
	hakuba.commitEditingHandler = { [weak self] style, indexPath in
		self?.hakuba[indexPath.section].remove(indexPath.row)
	}
```

* Deselect all cells

``` swift
	hakuba.deselectAllCells(animated: true)
```

* Dynamic cell height : when you want to enable dynamic cell height, you only need to set the value of estimated height to the `height` parameter and set `dynamicHeightEnabled = true`

``` swift
	let cellmodel = MYCellModel(cellClass: YourCell.self, height: 50, userData: yourCellData) {
		println("Did select cell")
	}
	cellmodel.dynamicHeightEnabled = true
	
```

* Callback methods in the cell class

``` swift
	func willAppear(data: MYCellModel)
	func didDisappear(data: MYCellModel)
```


Installation
-----
* Installation with CocoaPods

```
	pod 'Hakuba'
```

* Copying all the files into your project
* Using submodule

Requirements
-----
- iOS 7.0+
- Xcode 6.1

License
-----

Hakuba is released under the MIT license. See LICENSE for details.
