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

import Foundation

class SentimentAnalyser {
  enum Sentiment {
    case postive
    case negative
    case error
  }
  
  struct SentimentPrediction {
    let positive: Double
    let negative: Double
    var sentiment: Sentiment {
      if positive == 0 && negative == 0 {
        return .error
      }
      return positive > negative ? .postive : .negative
    }
  }
  
  private let featureGenerator = FeatureGenerator()
  private let model = MovieReviewSentiment()
  
  func predictSentiment(for text: String) -> SentimentPrediction {
    do {
      let featureVector = self.featureGenerator.featureVector(for: text)
      let prediction = try self.model.prediction(input: featureVector)
      print(prediction.classProbability)
      
      return SentimentPrediction(positive: prediction.classProbability["pos"]!,
                                 negative: prediction.classProbability["neg"]!)
    } catch let e {
      print(e)
      return SentimentPrediction(positive: 0, negative: 0)
    }
  }
}
