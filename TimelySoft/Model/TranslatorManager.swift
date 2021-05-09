import UIKit

protocol TranslatorManagerDelegate {
  func didUpdateLabels(_ manager: TranslatorManager, _ word: wordsModel)
  func didError(with error: Error)
}

class TranslatorManager {
  var delegate: TranslatorManagerDelegate?
  private let url = URL(string: "http://aucatranslator.azurewebsites.net/api/v1/wordtranslation/?word")!
  
  func fetchRequest(with url: String){
    if let finalURL = URL(string: "\(self.url)=\(url)"), let delegate = delegate {
      let request = URLRequest(url: finalURL)
      let session = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
        if let error = error {
          DispatchQueue.main.async {
            delegate.didError(with: error)
          }
        }
        if let safeData = data {
          guard let parsedData = parseJSON(with: safeData) else {
            return
          }
          DispatchQueue.main.async {
            delegate.didUpdateLabels(self, parsedData)
          }
        }
      }
      session.resume()
    }
  }
  
  private func parseJSON(with data: Data) -> wordsModel? {
    let decoder = JSONDecoder()
    do {
      let decodedData = try decoder.decode(wordsModel.self, from: data)
      let model = wordsModel(originalWord: decodedData.originalWord, translation: decodedData.translation)
      return model
    } catch {
      DispatchQueue.main.async {
        self.delegate?.didError(with: error)
      }
      return nil
    }
  }
  
  func saveToDefaults(_ words: [String]) {
    let words: [String] = words
    UserDefaults.standard.set(words, forKey: "words")
  }
}

extension UserDefaults {
  func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
    guard let data = self.value(forKey: key) as? Data else { return nil }
    return try? decoder.decode(type.self, from: data)
  }

  func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
    let data = try? encoder.encode(object)
    self.set(data, forKey: key)
  }
}
