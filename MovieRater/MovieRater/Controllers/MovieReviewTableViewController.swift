/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class MovieReviewTableViewController: UITableViewController {
  
  let sentimentAnalyser = SentimentAnalyser()
  let reviews = MovieReview.loadReviews()
  lazy var sections: [String] = {
    reviews.map({ (key, _) in
      return key
    })
  }()
  var sentimentPredictions = [MovieReview : SentimentAnalyser.SentimentPrediction]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    calculateSentiments()
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return reviews.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reviews[sections[section]]?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
   
    if let movieReviews = reviews[sections[indexPath.section]],
      let cell = cell as? MovieReviewTableViewCell {
      let review = movieReviews[indexPath.item]
      cell.sentimentPrediction = sentimentPredictions[review]
      cell.movieReview = review
    }
    
    return cell
  }
  
  private func calculateSentiments() {
    for section in sections {
      for review in reviews[section]! {
        DispatchQueue.global(qos: .userInitiated).async {
          let sentiment = self.sentimentAnalyser.predictSentiment(for: review.review)
          DispatchQueue.main.async {
            self.sentimentPredictions[review] = sentiment
          }
        }
      }
    }
  }
  
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView,
      let textLabel = header.textLabel else { return }
    
    textLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
  }
}
