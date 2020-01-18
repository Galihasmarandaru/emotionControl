//
//  ViewController_01.swift
//  emotionControl
//
//  Created by Galih Asmarandaru on 26/05/19.
//  Copyright © 2019 Galih Asmarandaru. All rights reserved.
//

import Foundation
import UIKit
import Speech

class ViewController_01: UIViewController, SFSpeechRecognizerDelegate {

    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id"))!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var speechResult = SFSpeechRecognitionResult()

    var a = 1
    
    @IBOutlet weak var colorView: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SFSpeechRecognizer.requestAuthorization { authStatus in

            OperationQueue.main.addOperation {
                var alertTitle = ""
                var alertMsg = ""

                switch authStatus {
                case .authorized:
                    do {
                        try self.startRecording()
                    } catch {
                        alertTitle = "Recorder Error"
                        alertMsg = "There was a problem starting the speech recorder"
                    }

                case .denied:
                    alertTitle = "Speech recognizer not allowed"
                    alertMsg = "You enable the recgnizer in Settings"

                case .restricted, .notDetermined:
                    alertTitle = "Could not start the speech recognizer"
                    alertMsg = "Check your internect connection and try again"

                @unknown default:
                    fatalError()
                }
                if alertTitle != "" {
                    let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))

                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorView.layer.cornerRadius = colorView.frame.size.width/2
    }

    private func startRecording() throws {
        if !audioEngine.isRunning {
            let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(ViewController_01.timerEnded), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create the recognition request") }
            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false

                if let result = result {
                    print("result: \(result.isFinal)")
                    isFinal = result.isFinal

                    let strContent = result.bestTranscription.formattedString.lowercased()

                    self.speechResult = result
                    self.checkForColorSaid(resultString: strContent)
                }

                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)

                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }

            print("Begin recording")
            audioEngine.prepare()
            try audioEngine.start()
        }

        if a == 11 {
            dismiss(animated: true, completion: nil)
        }

    }

    func checkForColorSaid(resultString: String) {
        if resultString.contains("bahagia") {
            a += 1
            UIView.animate(withDuration: 1, delay: 0.8, animations: {
                self.colorView.backgroundColor = .green
                self.colorView.transform = CGAffineTransform(scaleX: CGFloat(self.a), y: CGFloat(self.a))
            }) { (isFinish) in
            }
        } else if resultString.contains("baik") {
            a += 1
            UIView.animate(withDuration: 1, delay: 0.8, animations: {
                self.colorView.backgroundColor = .yellow
                self.colorView.transform = CGAffineTransform(scaleX: CGFloat(self.a), y: CGFloat(self.a))
            }) { (isFinish) in
            }
        } else if resultString.contains("buruk") {
            a -= 1
            UIView.animate(withDuration: 1, delay: 0.8, animations: {
                self.colorView.backgroundColor = .gray
                self.colorView.transform = CGAffineTransform(scaleX: CGFloat(self.a), y: CGFloat(self.a))
            }) { (isFinish) in
            }
        }
        stopRecording()
    }

    @objc func timerEnded() {
        if !audioEngine.isRunning {
        do {
            try self.startRecording()
        } catch {
            print("interval")
        }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        print("Stop recording")
    }
}
