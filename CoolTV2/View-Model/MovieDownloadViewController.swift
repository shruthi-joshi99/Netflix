//
//  MovieDownloadViewController.swift
//  CoolTV2
//
//  Created by Shantanu Joshi on 18/01/24.
//

import UIKit
import AVFoundation
import AVKit
import CoreData

class MovieDownloadViewController: UIViewController {
    
    var filePath: URL? = nil
    private var observation: NSKeyValueObservation?
    var task: URLSessionDataTask? = nil

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadingInfoLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var downloadProgressLabel: UILabel!
    
    deinit {
      observation?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
    
    @IBAction func downloadBtnClicked(_ sender: Any) {
        saveVideoInApp(movieName, urlString)
    }
    
    @IBAction func pauseBtnTapped(_ sender: Any) {
        if pauseButton.imageView?.image == UIImage(systemName: "pause.fill") {
            pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            downloadProgressLabel.text = "Download paused"
            task?.suspend()
        } else {
            pauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            downloadProgressLabel.text = "Downloading, please wait"
            task?.resume()
        }
        
    }
    
    func setUpUI() {
        previewImage.image = UIImage(named: movieName)
        titleLabel.text = movieName
        downloadButton.layer.cornerRadius = 4
        progressView.isHidden = true
        progressLabel.isHidden = true
        pauseButton.isHidden = true
        downloadingInfoLabel.isHidden = true
        downloadButton.isEnabled = true
    }
    
    func changeUI() {
        downloadButton.isEnabled = false
        progressView.progress = 0.0
        progressView.isHidden = false
        progressLabel.isHidden = false
        pauseButton.isHidden = false
        downloadingInfoLabel.isHidden = false
    }
    
    func saveVideoInApp(_ movieName: String, _ urlString: String) {
        let videoUrl = urlString
        
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationUrl = docsUrl.appendingPathComponent("\(movieName).mp4")
        if(FileManager().fileExists(atPath: destinationUrl.path)){
            print("\n\nfile already exists\n\n")
            self.displayAlert()
        }
        else{
            changeUI()
            var request = URLRequest(url: URL(string: videoUrl)!)
            request.httpMethod = "GET"
            task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
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
                                    self.saveInCoreData()
                                }
                                else{
                                    print("\n\nerror again\n\n")
                                }
                            }
                        }
                    }
                }
            })
            observation = task?.progress.observe(\.fractionCompleted) { progress, _ in
                print("progress: ", progress.fractionCompleted)
                DispatchQueue.main.async {
                    self.progressView.progress = Float(progress.fractionCompleted)
                    let formatted = String(format: "%.2f", progress.fractionCompleted * 100)
                    self.progressLabel.text = "\(formatted)%"
                }
            }
            task?.resume()
        }
    }
    
    func displayAlert() {
        let alert = UIAlertController(title: nil, message: "You have already downloaded the movie.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.playVideoInAVPlayer()
    }
    
    func playVideoInAVPlayer() {
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let assetUrl = baseUrl.appendingPathComponent("\(movieName).mp4")
        
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
    
    func saveInCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let downloadedList = Downloaded(context: context)
        downloadedList.movieName = movieName
        
        do {
            try context.save()
        } catch {
            print("saving error: \(error.localizedDescription)")
        }
    }
    
}
