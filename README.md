MYTableViewManager
===========

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/nghialv/MYTableViewManager.svg?style=flat
)](https://github.com/nghialv/MYTableViewManager/issues?state=open)

I want to slim down my view controllers.

I want to manage tableview without the code of `UITableViewDelegate` and `UITableViewDataSource`.

That is why I created `MYTableViewManager`.

Feature
-----
* Don't have to write the code for `UITableViewDelegate` and `UITableViewDataSource` protocols
* Don't have to set cell identifier
* Handling cell selection by trailing closure
* Easy to manage your cells (append/reset/insert/remove/update)
* Easy to implement header/footer view
* Support dynamic cell height from **ios7**
* Support for creating cells from Nibs or Storyboards
* Method chaining
* Subscript
* Easy to implement loadmore
* Complete example

##### Quick example

``` swift
	// viewController class
	@IBOutlet weak var tableView: UITableView!
	private var tvm: MYTableViewManager!

	override func viewDidLoad() {
		super.viewDidLoad()
		tvm = MYTableViewManager(tableView: tableView)
		
		let title = "Cell Title"
		let cellmodel = MYCellModel(cellClass: CustomCell.self, userData: title) {
			println("Did select cell with title = \(title)")
		}
		
		// append a new cell in section `0` with `Fade` animation
		
		tvm[0].append(cellmodel)
			  .fire(.Fade)
	}       
```
``` swift
	// your custom cell class
	class CustomCell : MYTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func configureCell(data: MYCellModel) {
        super.configureCell(data)
        if let title = data.userData as? String {
            titleLabel.text = title
        }
      }
	}
```

Usage
-----

 * Initilization

``` swift
	private var tvm = MYTableViewManager(tableView: tableView)   
```

* Create cell view-model

``` swift
	// create a cell-model
	let cellmodel = MYCellModel(cellClass: CustomCell.self, userData: celldata) {
		println("Did select")
	}
	
	// create a list of view-model from api results
	let items = [...] // or your data from API

    let cellmodels = items.map { item -> MYCellModel in
        return MYCellModel(cellClass: CustomCell.self, userData: item) {
            println("Did select cell")
        }
    }
```

* Register cell, header, footer

``` swift
	tvm.registerCellNib(CellClassName)
	tvm.registerCellClass(CellClassName)
	tvm.registerHeaderFooterNib(HeaderOrFooterClassName)
	tvm.registerHeaderFooterClass(HeaderOrFooterClassName)
```

* Section handling

``` swift
	let section = MYSection()
	tvm.insertSection(section, atIndex: 1)
	   .fire()
	
	tvm.removeSectionAtIndex(index)
	   .fire(.Left)
	   
	tvm.removeAllSection()
	   .fire()
	
	// get or create section by the following simple syntax
	let section = tvm[index]
```

* View-Model handling

``` swift
	// appending
	
	tvm[0].append(cellmodel)
		  .fire(.Fade)
		  
	// create section 1 and append a list of cells
	tvm[1].append(cellmodels)
		  .fire(.Left)					// fire with `Left` animation
		  
	// or using section
	section.append(cellmodel)
		    .fire()
```

``` swift
	// you can insert a cell-model or an array of cell-models
	
	tvm[1].insert(cellmodels, atIndex: 1)
		  .fire(.Middle)
```

``` swift
	// replace current data in section by the new data
	tvm[1].reset(cellmodels)
		  .fire()
```

``` swift
	// inserting
	section.insert(cellmodel, atIndex: 1).fire()
	section.insert(cellmodels, atIndex: 2).fire(.Left)
```


``` swift
	// removing
	section.remove(1).fire()
	section.remove((2...5))
	section.removeLast().fire()
```

``` swift
	section.sort().fire()
	section.shuffle().fire()
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

* Update view-model

``` swift
	tvm[0][1].property = newData
	tvm[0][1].fire()		
```

* Set header/footer view

``` swift
	let viewmodel = MYHeaderFooterViewModel(viewClass: CustomHeaderView.self, userData: nil) {
		println("Did select header view")
	}
	tvm[0].header = viewmodel
	
	// hide header in section 1
	tvm[1].header?.hidden = true
```

* loadmore

``` swift
	tvm.loadmoreEnabled = true
	tvm.loadmoreHandler = {
		
	}
```

* deselect all cells

``` swift
	tvm.deselectAllCells(animated: true)
```

* Dynamic cell height : when you want to enable dynamic cell height, you only need to set the value of estimated height to the `height` parameter and set `dynamicHeightEnabled = true`

``` swift
	let cellmodel = MYCellModel(cellClass: CustomClass.self, height: 50, userData: yourCellData) {
		println("Did select cell")
	}
	cellmodel.dynamicHeightEnabled = true
	
```

* Callback methods in the cell class

``` swift
	func willAppear(data: MYCellModel)
	func didDisappear(data: MYCellModel)
```

TODO
-----

- [x] prototyping
- [x] append/reset
- [x] insert
- [x] remove
- [x] update
- [x] header/footer
- [x] dynamic height for cells
- [x] dynamic height example
- [x] update data on the main thread
- [x] loadmore
- [x] create podfile
- [ ] section handling

Installation
-----
* Installation with CocoaPods

```
	pod 'MYTableViewManager'
```

* Copying all the files into your project
* Using submodule

Requirements
-----
- iOS 7.0+
- Xcode 6.1

License
-----

MYTableViewManager is released under the MIT license. See LICENSE for details.
