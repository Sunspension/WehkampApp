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

    private var _items = [ProductViewModel]()
    
    private let _bag = DisposeBag()
    
    private lazy var _refresh: UIRefreshControl = {
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.requestBasket), for: .valueChanged)
        return control
    }()
    
    var viewModel: BasketViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Basket"
        
        setupNavigationItem()
        setupTableView()
        setupRefresh()
        setupViewModel()
        requestBasket()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return _items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductCell
        let product = _items[indexPath.row]
        cell.configure(product, indexPath)
        
        return cell
    }
    
    // MARK: - ScrollView delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if _refresh.isRefreshing { self.requestBasket() }
    }
    
    // MARK: - Private methods
    
    private func setupNavigationItem() {
        
        let logout = UIBarButtonItem()
        logout.title = "Logout"
        viewModel.logoutAction = logout.rx.tap.asObservable()
        navigationItem.leftBarButtonItem = logout
        
        let addItem = UIBarButtonItem()
        addItem.title = "Add"
        viewModel.addItemAction = addItem.rx.tap.asObservable()
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func setupTableView() {
        
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        let nib = UINib(nibName: String(describing: ProductCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    private func setupRefresh() {
        
        if #available(iOS 10.0, *) {
            
            self.tableView.refreshControl = _refresh
        }
        else {
            
            self.refreshControl = _refresh
        }
    }
    
    private func setupViewModel() {
        
        viewModel.deleteItemAction.bind { [unowned self] indexPath in
            
            self._items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            }.disposed(by: _bag)
    }
    
    @objc private func requestBasket() {
        
        if self.tableView.isDragging { return }
        
        viewModel.requestBasket()
            .subscribe(onNext: { [weak self] in
                
                self?._refresh.endRefreshing()
                self?.updateDataSource($0)
                
                }, onError: { [weak self] in
                    
                    self?._refresh.endRefreshing()
                    debugPrint($0)
            })
            .disposed(by: _bag)
    }
    
    private func updateDataSource(_ items: [ProductViewModel]) {
        
        _items = items
        tableView.reloadSections([0], with: .automatic)
    }
}
