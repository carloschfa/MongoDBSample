//
//  Created by Carlos Henrique Antunes on 2/26/20.
//  Copyright © 2020 Carlos Henrique Antunes. All rights reserved.
//

import UIKit
import StitchCore
import StitchRemoteMongoDBService

class ObjectsView: UIViewController {

	@IBOutlet var tableView: UITableView!

  private var listener: ChangeStreamSession<Object>?

	private var filter: [String] = ["Category1", "Category2", "Categroy3"]
	private var categories: [String] = ["Category1", "Category2", "Categroy3"]

	private var objectIds: [String] = []
	private var objects: [String: Any] = [:]

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Test"

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(actionFilter))

		let buttonAdd = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(actionAdd))
		let buttonFetch = UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(actionFetch))
		navigationItem.rightBarButtonItems = [buttonAdd, buttonFetch]

		tableView.tableFooterView = UIView()
    
    self.fetchObjects()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		createObserver()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		removeObserver()
	}

	// MARK: - Backend methods (observer)
  func createObserver() {
    do {
      let query: Document = [
        "fullDocument.category": [
          "$in": filter] as Document
        ] as Document
        
      listener = try objectsCollection.watch(matchFilter: query, delegate: self)
    } catch {
      NSLog("Stitch error: \(error)")
    }
	}

	func addObject(_ object: [String: Any]) {

		if let objectId = object["objectId"] as? String {
			if (objectIds.contains(objectId) == false) {
				objectIds.insert(objectId, at: 0)
			}
			objects[objectId] = object
		}
	}

  func removeObserver() {
    listener?.close()
    listener = nil
	}

	// MARK: - Backend methods (fetch)
  func fetchObjects() {
    let query: Document = [
      "category": [
        "$in": filter] as Document
      ] as Document
    
    objectsCollection.find(query).toArray { result in
      switch result {
      case .success(let objects):
        self.objectIds.removeAll()
        self.objects.removeAll()
        for object in objects {
          do {
            self.objects[object.objectId] = try object.asDictionary()
            self.objectIds.append(object.objectId)
          } catch {
            NSLog(error.localizedDescription)
          }
        }
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      case .failure(let error):
        NSLog(error.localizedDescription)
      }
    }
	}

	// MARK: - Backend methods (create, update)
  func createObject(_ category: String) {
    let object = Object(objectId: UUID().uuidString,
                        category: category,
                        text: randomText(),
                        number: randomInt(),
                        boolean: randomBool(),
                        createdAt: Date().string(),
                        updatedAt: Date().string())
    
    objectsCollection.insertOne(object) { (result) in
      switch result {
      case .failure(let error):
        NSLog(error.localizedDescription)
      case .success:
        NSLog("Added with success.")
      }
    }
	}
  
  func deleteObject(_ object: [String: Any]) {
      guard
        let objectId = object["objectId"] as? String,
        let index = objects.index(forKey: objectId),
        let indexPath = objectIds.firstIndex(of: objectId)
      else { return }
      
      objectsCollection.deleteOne(["objectId": objectId]) { (result) in
        switch result {
        case .failure(let error):
          NSLog(error.localizedDescription)
        case .success(_):
          self.objects.remove(at: index)
          self.objectIds.removeAll(where: { $0 == objectId })
          DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(row: indexPath, section: 0)], with: .none)
          }
      }
    }
  }

  func updateObject(_ object: [String: Any]) {

    guard
      let objectId = object["objectId"] as? String,
      let index = objectIds.firstIndex(of: objectId)
      else { return }
      
    var object = object

    object["text"] = randomText()
    object["number"] = randomInt()
    object["boolean"] = randomBool()
    object["updatedAt"] = Date().string()
      
    let update: Document = ["$set": [
        "text":  object["text"] as! String,
        "number": object["number"] as! Int,
        "boolean": object["boolean"] as! Bool,
        "updateAt": object["updatedAt"] as! String
      ] as Document
    ] as Document
      
    objectsCollection.updateOne(filter: ["objectId": objectId], update: update) { (result) in
      switch result {
      case .failure(let error):
        NSLog(error.localizedDescription)
      case .success(_):
        self.objects[objectId] = object
        DispatchQueue.main.async {
          self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
      }
    }
	}

	// MARK: - User actions
	@objc func actionFilter() {

		let filterView = FilterView(filter: filter)
		filterView.delegate = self
		let navController = UINavigationController(rootViewController: filterView)
		present(navController, animated: true)
	}

	@objc func actionFetch() {
		fetchObjects()
	}

	@objc func actionAdd() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		for category in categories {
			alert.addAction(UIAlertAction(title: category, style: .default, handler: { action in
				self.createObject(category)
			}))
		}

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	// MARK: - Helper methods
	func randomText() -> String {
		return String((0..<20).map { _ in "abcde".randomElement()! })
	}

	func randomInt() -> Int {
		return Int.random(in: 1000..<5000)
	}

	func randomBool() -> Bool {
		return Bool.random()
	}
}

// MARK: - FilterDelegate
extension ObjectsView: FilterDelegate {

	func didSelectFilter(filter: [String]) {

		self.filter = filter

		objectIds.removeAll()
		objects.removeAll()

		removeObserver()
		createObserver()
	}
}

// MARK: - UITableViewDataSource
extension ObjectsView: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objectIds.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if (cell == nil) { cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell") }

		let objectId = objectIds[indexPath.row]

		cell.textLabel?.text = objectId
		cell.textLabel?.font = UIFont.systemFont(ofSize: 13)

		cell.detailTextLabel?.text = ""
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)

		if let object = objects[objectId] as? [String: Any] {
			if let category = object["category"] as? String, let text = object["text"] as? String,
				let number = object["number"] as? Int, let boolean = object["boolean"] as? Bool {
				cell.detailTextLabel?.text = "\(category) - \(text) - \(number) - \(boolean)"
			}
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
extension ObjectsView: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		let objectId = objectIds[indexPath.row]

		if let object = objects[objectId] as? [String: Any] {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
				self.updateObject(object)
			}
		}
	}
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        let objectId = objectIds[indexPath.row]

        if let object = objects[objectId] as? [String: Any] {
          self.deleteObject(object)
        }
    }
  }
}

// MARK: - ChangeStreamDelegate
extension ObjectsView: ChangeStreamDelegate {
  typealias DocumentT = Object
  
  func didReceive(event: ChangeEvent<Object>) {
    if let object = event.fullDocument {
      DispatchQueue.main.async { [weak self] in
        do {
          self?.addObject(try object.asDictionary())
          self?.tableView.reloadData()
        } catch {
          NSLog(error.localizedDescription)
        }
      }
    } else if let objectId = event.documentKey["objectId"] as? String {
      DispatchQueue.main.async { [weak self] in
        self?.objects.removeValue(forKey: objectId)
        self?.objectIds.removeAll(where: { $0 == objectId })
        self?.tableView.reloadData()
      }
    }
  }
  
  func didReceive(streamError: Error) {
    NSLog(streamError.localizedDescription)
  }
  
  func didOpen() { }
  
  func didClose() { }
  
}

extension Date {
  func string(format: String? = nil) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format ?? "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter.string(from: self)
  }
}
