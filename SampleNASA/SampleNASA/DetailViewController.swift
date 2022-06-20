//
//  ViewController.swift
//  SampleNASA
//
//  Created by Rayan Godwin Sequeira on 18/06/22.
//

import UIKit

class DetailViewController: UIViewController
{
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var explanationLabel: UILabel!
    @IBOutlet var imageErrorLabel: UILabel!
    @IBOutlet var imageDownloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var refreshButton: UIButton!
    
    let viewModel = PlanetaryViewModel()
    var dateString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.startDonwloadOfCurrentItem()
    }
    
    @IBAction func refreshViewTouched(_ sender: Any)
    {
        self.startDonwloadOfCurrentItem()
    }
    
    private func startDonwloadOfCurrentItem()
    {
        self.startLoadingView()
        self.viewModel.fetchItemOfTheDay(dateString: self.dateString,
                                         modelDownloadCompletion: {[weak self] result in
            self?.updateUIWith(result: result)
        },
                                         imageDownloadCompletion : { [weak self] result in
            self?.handleImageDownload(result: result)
        })
    }
    
    private func updateUIWith(result: Result<PlanetaryModelToDisplay, Error>)
    {
        switch result
        {
        case .success(let modelToDisplay):
            self.updateTextLabelsWith(model: modelToDisplay)
            
        case .failure( _):
            self.showErrorView()
        }
    }
    
    private func updateTextLabelsWith(model: PlanetaryModelToDisplay)
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text = model.title
            self.dateLabel.text = model.displayDate
            self.explanationLabel.text = model.explanation
            self.activityIndicator.stopAnimating()
            self.errorLabel.isHidden = true
            self.refreshButton.isHidden = true
        }
    }
    
    private func startLoadingView()
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.startAnimating()
            self.imageDownloadActivityIndicator.startAnimating()
            self.imageErrorLabel.isHidden = true
            self.errorLabel.isHidden = true
            self.scrollView.isHidden = false
            self.titleLabel.text = ""
            self.dateLabel.text = ""
            self.explanationLabel.text = ""
            self.imageView.image = nil
        }
    }
    
    private func handleImageDownload(result: Result<UIImage, Error>)
    {
        switch result
        {
        case .success(let image):
            self.updateImageView(image: image)
            
        case.failure(_):
            self.updateImageError()
        }
    }
    
    private func updateImageView(image: UIImage)
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageDownloadActivityIndicator.stopAnimating()
            self.imageView.image = image
            self.imageErrorLabel.isHidden = true
        }
    }
    
    private func updateImageError()
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imageDownloadActivityIndicator.stopAnimating()
            self.imageErrorLabel.isHidden = false
        }
    }
    
    private func showErrorView()
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorLabel.isHidden = false
            self.scrollView.isHidden = true
            self.imageDownloadActivityIndicator.stopAnimating()
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func hideErrorView()
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.errorLabel.isHidden = true
            self.scrollView.isHidden = false
        }
    }
}

