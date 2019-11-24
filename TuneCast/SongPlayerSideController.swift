//
//  SongPlayerSideController.swift
//  TuneCast
//
//  Created by Kenneth Galang on 2019-11-23.
//  Copyright © 2019 CARFAX Ca. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func encodeStringAsUrlParameter(_ value: String) -> String {
        let escapedString = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return escapedString!
    }
}

extension Dictionary {

    func urlParametersRepresentation() -> String {
        // Add the necessary parameters
        var pairs = [String]()
        for (key, value) in self {
            let keyString = key as! String
            let valueString = value as! String
            let encodedKey = keyString.encodeStringAsUrlParameter(key as! String)
            let encodedValue = valueString.encodeStringAsUrlParameter(value as! String)
            let encoded = String(format: "%@=%@", encodedKey, encodedValue);
            pairs.append(encoded)
        }

        return pairs.joined(separator: "&")
    }
}




class PlaybackButtonGraphics {
    class func imageWithFilledPolygons(_ lines: [[CGPoint]]) -> UIImage {
        let context = CGContext(data: nil,
                                            width: 64, height: 64,
                                            bitsPerComponent: 8, bytesPerRow: 8*64*4,
                                            space: CGColorSpaceCreateDeviceRGB(),
                                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue);
        
        let path = CGMutablePath()
        for linePoints in lines {
            path.addLines(between: linePoints)
        }
        
        context?.addPath(path)
        context?.fillPath()

        if let image = context?.makeImage() {
            return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
        }
        
        return UIImage()
    }
    
    class func playButtonImage() -> UIImage {
        return imageWithFilledPolygons([[
            CGPoint(x: 64, y: 32),
            CGPoint(x: 0, y: 64),
            CGPoint(x: 0, y: 0),
            ]])
    }
    
    class func nextButtonImage() -> UIImage {
        return imageWithFilledPolygons([
            [
                CGPoint(x: 64, y: 32),
                CGPoint(x: 32, y: 48),
                CGPoint(x: 32, y: 16),
            ], [
                CGPoint(x: 32, y: 32),
                CGPoint(x: 0, y: 48),
                CGPoint(x: 0, y: 16),
            ]])
    }
    
    class func previousButtonImage() -> UIImage {
        return imageWithFilledPolygons([
            [
                CGPoint(x: 32, y: 32),
                CGPoint(x: 64, y: 48),
                CGPoint(x: 64, y: 16),
            ], [
                CGPoint(x: 0, y: 32),
                CGPoint(x: 32, y: 48),
                CGPoint(x: 32, y: 16),
            ]])
    }
    
    class func pauseButtonImage() -> UIImage {
        let context = CGContext(data: nil,
                                            width: 64, height: 64,
                                            bitsPerComponent: 8, bytesPerRow: 8*64*4,
                                            space: CGColorSpaceCreateDeviceRGB(),
                                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue);
        
        context?.fill(CGRect(x: 0, y: 0, width: 20, height: 64));
        context?.fill(CGRect(x: 44, y: 0, width: 20, height: 64));
        if let image = context?.makeImage() {
            return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
        }
        
        return UIImage()
    }
}


class ConnectionStatusIndicatorView : UIView {
    
    enum State {
        case disconnected
        case connecting
        case connected
    }
    
    var state: State = .disconnected {
        didSet {
            self.setNeedsDisplay()
            if state == .connecting {
                if displayLink == nil {
                    let selector = #selector(setNeedsDisplay as () -> Void)
                    displayLink = CADisplayLink(target: self, selector:selector)
                }
                displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            } else {
                displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
                displayLink = nil;
            }
        }
    }
    
    var displayLink: CADisplayLink?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.clearsContextBeforeDrawing = true;
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let size = self.bounds.size
        let path = CGMutablePath()
        
        path.__addRoundedRect(transform: nil, rect: self.bounds, cornerWidth: size.width/2, cornerHeight: size.height/2)
        context.addPath(path)
        
        context.setFillColor(fillColor())
        context.fillPath()
    }
    
    private func timebasedValue() -> CGFloat {
        return CGFloat(abs(sin(Date().timeIntervalSinceReferenceDate*4)))
    }
    
    private func fillColor() -> CGColor {
        switch state {
        case .disconnected:
            return UIColor.red.cgColor
        case .connecting:
            return UIColor.orange.withAlphaComponent(0.5+timebasedValue()*0.3).cgColor
        case .connected:
            return UIColor.green.cgColor
        }
    }
}

protocol SpeedPickerViewControllerDelegate {
    func speedPicker(viewController: SpeedPickerViewController, didChoose speed:SPTAppRemotePodcastPlaybackSpeed)
    func speedPickerDidCancel(viewController: SpeedPickerViewController)
}


class SpeedPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SpeedPickerViewControllerDelegate?
    private let podcastSpeeds: [SPTAppRemotePodcastPlaybackSpeed]
    private var selectedSpeed: SPTAppRemotePodcastPlaybackSpeed
    private var selectedIndex: Int = 0
    private let cellIdentifier = "SpeedCell"

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        return tableView
    }()

    init(podcastSpeeds: [SPTAppRemotePodcastPlaybackSpeed], selectedSpeed: SPTAppRemotePodcastPlaybackSpeed) {
        self.podcastSpeeds = podcastSpeeds
        self.selectedSpeed = selectedSpeed
        super.init(nibName: nil, bundle: nil)
        updateSelectedindex()
        view.addSubview(tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Podcast Playback Speed"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didPressCancel))
    }

    private func updateSelectedindex() {
        let values = podcastSpeeds.map { $0.value }
        selectedIndex = values.distance(from: values.startIndex, to:values.firstIndex(of: self.selectedSpeed.value)!)
    }

    @objc func didPressCancel() {
        delegate?.speedPickerDidCancel(viewController: self)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.speedPicker(viewController: self, didChoose: podcastSpeeds[indexPath.row])
        selectedSpeed = podcastSpeeds[indexPath.row]
        selectedIndex = indexPath.row
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastSpeeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = String(format: "%.1fx", podcastSpeeds[indexPath.row].value.floatValue)
        if indexPath.row == selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
