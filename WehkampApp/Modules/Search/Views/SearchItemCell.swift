//
//  SearchItemCell.swift
//  WehkampApp
//
//  Created by Vladimir Kokhanevich on 15/09/2018.
//  Copyright © 2018 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RxSwift
import AlamofireImage

class SearchItemCell: UITableViewCell {

    private var _bag = DisposeBag()
    
    @IBOutlet private weak var container: UIView!
    
    @IBOutlet private weak var itemImage: UIImageView!
    
    @IBOutlet private weak var itemTitle: UILabel!
    
    @IBOutlet private weak var itemPrice: UILabel!
    
    @IBOutlet private weak var addItem: UIButton!
    
    @IBOutlet weak var busy: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .background
        container.layer.cornerRadius = 15
        setupShadow()
        
        addItem.layer.cornerRadius = 8
        addItem.addShadow(offset: CGSize(width: 0, height: 5), color: UIColor.babyBlue, radius: 8, opacity: 0.1)
    }

    override func prepareForReuse() {
        
        _bag = DisposeBag()
        itemImage?.image = nil
        setupShadow()
    }
    
    private func setupShadow() {
        
        container.addShadow(offset: CGSize(width: 0, height: 5), radius: 8, opacity: 0.1)
        container.rx.observe(CGRect.self, "bounds")
            .bind { [unowned self] bounds in
                
                guard let bounds = bounds else { return }
                
                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
                self.container.layer.shadowPath = path
                
            }.disposed(by: _bag)
    }
}


extension SearchItemCell {
    
    func configure(_ viewModel: SearchItemViewModelProtocol) {
        
        itemTitle.text = viewModel.itemName
        itemPrice.text = viewModel.price
        
        let width = Int(UIScreen.main.scale * itemImage.bounds.width)
        let resize = "?w=\(width)"
        
        if let url = URL(string: viewModel.productImage + resize) {
            
            itemImage.af_setImage(withURL: url,
                                  imageTransition: .crossDissolve(0.3),
                                  runImageTransitionIfCached: true) { _ in self.busy.stopAnimating() }
        }
        
        addItem.rx.tap.bind { viewModel.addItemToBasket() }.disposed(by: _bag)
    }
}
