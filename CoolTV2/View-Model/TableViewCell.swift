//
//  TableViewCell.swift
//  CoolTV2
//
//  Created by Shantanu Joshi on 18/01/24.
//

import UIKit


protocol MovieSelectionDelegate {
    func passMovie()
}

class TableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var viewController: ViewController?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: MovieSelectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[collectionView.tag].movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.images.image = UIImage(named: data[collectionView.tag].movies[indexPath.row])
        cell.titleLabel.text = data[collectionView.tag].movies[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 170, height: 170)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let item = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        movieName = item.titleLabel.text ?? " "
        urlString = urlData[movieName] ?? " "
        delegate?.passMovie()
        viewController?.performSegue(withIdentifier: "showMovieInfoSegue", sender: nil)
    }
    
}
