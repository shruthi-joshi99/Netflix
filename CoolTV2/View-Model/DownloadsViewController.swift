//
//  DownloadsViewController.swift
//  CoolTV2
//
//  Created by Shantanu Joshi on 18/01/24.
//

import UIKit
import CoreData
import AVFoundation
import AVKit

class DownloadsViewController: UIViewController {
    
    var downloadedList: [Downloaded] = []
    var movieName = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDownloads()
        print(downloadedList)
        tableView.reloadData()
    }
    
    func fetchDownloads() {
        var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            downloadedList = try context.fetch(Downloaded.fetchRequest())
            print(downloadedList)
        } catch {
            print("fetching error: \(error.localizedDescription)")
        }
    }
    
    
}

extension DownloadsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DownloadsTableViewCell
        cell.images.image = UIImage(named: downloadedList[indexPath.row].movieName ?? " " )
        cell.label.text = downloadedList[indexPath.row].movieName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DownloadsTableViewCell
        let movieName = downloadedList[indexPath.row].movieName ?? " "
        saveVideoInApp(self.movieName, urlData[movieName] ?? " ")
    }
    
    func playVideoInAVPlayer() {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let assetUrl = baseUrl.appendingPathComponent("\(movieName).mp4")
        //        guard let assetUrl = downloads[movieName]  else { return }
        let url = assetUrl
        print(url)
        let avAssest = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: avAssest)
        
        
        let player = AVPlayer(playerItem: playerItem)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true, completion: {
            player.play()
        })
    }
    func saveVideoInApp(_ movieName: String, _ urlString: String) {
        let videoUrl = urlString
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = docsUrl.appendingPathComponent("\(movieName).mp4")
        if(FileManager().fileExists(atPath: destinationUrl.path)){
            print("\n\nfile already exists\n\n")
            playVideoInAVPlayer()
        }
        else{
            var request = URLRequest(url: URL(string: videoUrl)!)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if(error != nil){
                    print("\n\nsome error occured\n\n")
                    return
                }
                if let response = response as? HTTPURLResponse{
                    if response.statusCode == 200{
                        DispatchQueue.main.async {
                            if let data = data{
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic){
                                    print("\n\nurl data written\n\n")
                                    downloads[movieName] = destinationUrl
                                    self.playVideoInAVPlayer()
                                }
                                else{
                                    print("\n\nerror again\n\n")
                                }
                            }
                        }
                    }
                }
            }).resume()
        }
    }
    
}
