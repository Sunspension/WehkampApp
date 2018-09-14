//
//  BasketViewController.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 13/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift

class BasketViewController: UITableViewController {

    private var dataSource = [ProductViewModel]()
    
    private let _bag = DisposeBag()
    
    var viewModel: BasketViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basket"
        
        setupNavigationItem()
        setupTableView()
        requestBasket()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }

    
    // MARK: - Private methods
    
    private func setupNavigationItem() {
        
        let logout = UIBarButtonItem()
        logout.title = "Logout"
        viewModel.logoutAction = logout.rx.tap.asObservable()
        navigationItem.leftBarButtonItem = logout
        
        let addItem = UIBarButtonItem()
        addItem.title = "AddItem"
        viewModel.addItemAction = addItem.rx.tap.asObservable()
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func setupTableView() {
        
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: String(describing: ProductCell.self), bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    private func requestBasket() {
        
        viewModel.requestBasket()
            .subscribe(onNext: { [weak self] in self?.updateDataSource($0) }, onError: { debugPrint($0) })
            .disposed(by: _bag)
    }
    
    private func updateDataSource(_ items: [ProductViewModel]) {
        
        dataSource = items
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductCell
        let product = dataSource[indexPath.row]
        cell.configure(product)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
