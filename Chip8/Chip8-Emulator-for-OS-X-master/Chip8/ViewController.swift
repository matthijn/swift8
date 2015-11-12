//    The MIT License (MIT)
//
//    Copyright (c) 2015 Krzysztof Rossa
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Cocoa

class ViewController: NSViewController, CPUProtocol {

    @IBOutlet var screenView: ScreenView!
    
    @IBOutlet weak var programPath: NSTextFieldCell!
    
    @IBOutlet weak var soundCheckButton: NSButton!
    
    var isPlaySound = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func viewWillDisappear() {
        if let cpu = self.cpu {
            cpu.stopRuning()
        }
    }
    
    override func viewDidAppear() {
        
    }
    
    var cpu : CPU?;

    var filePath : String = ""

    func startCPU() {

        if (filePath.isEmpty) {
            print("no program")
        } else {
            self.cpu = CPU()

            if let cpu = self.cpu {
                screenView.setCPU(cpu)
                cpu.setListner(self)
                cpu.loadProgramFromFile(filePath)
                cpu.startProgram()
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // CPUProtocol
    func onOptocodeExecuted() -> Void {
        let keys = screenView.getKeys()

        if let cpu = self.cpu {
            cpu.setKeyboard(keys)
        }
        //screenView.setNeedsDisplay()
    }

    var needDisplay = false
    func setNeedDisplay() {
        needDisplay = true
    }
    
    var resourcePath : String? = NSBundle.mainBundle().pathForResource("beep-02", ofType:"wav")
    var sound : NSSound?
    
    func playSound() {
        if self.isPlaySound {
            if let resource = resourcePath {
                if sound == nil {
                    sound = NSSound(contentsOfFile:resource, byReference:true)
                }
                
                if let s = sound {
                    s.volume = 0.005
                    s.play()
                }
            }
        }
    }

    @IBAction func onLoad(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
//        openPanel.allowedFileTypes = ["ch8"]
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                //Do what you will
                //If there's only one URL, surely 'openPanel.URL'
                //but otherwise a for loop works
                print(result)
                
                let rootPath : NSURL? = openPanel.URL
                if let url = rootPath {
                    print(url)
                    print(url.path)
                    
                    if let value = url.path {
                        self.filePath = value
                        
                        self.filePath = value
                        if let _ = url.pathExtension {
                            self.programPath.stringValue = self.filePath
                        }
                        
                    }
                }
            
            }
        }
    }

    @IBAction func onNextInstuction(sender: NSButton) {
//        if let cpu = self.cpu {
//            cpu.decodeOptocode()
//        }
//        screenView.setNeedsDisplay()

        if let cpu = self.cpu {
            cpu.stopRuning()
        }
    }

    var thread : NSThread?
    
    @IBAction func onButtonStart(sender: NSButton) {

        if let th = self.thread {
            if let cpu = self.cpu {
                cpu.stopRuning()
            }

            print("canceled = \(th.cancelled)")
        }

        //start thread with cpu emulator
        thread = NSThread(target:self, selector:"startCPU", object:nil)
        if let th = self.thread {
            th.start()
        }
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60,
            target: self,
            selector: Selector("update"),
            userInfo: nil,
            repeats: true)
        
    }
    
    func update() {
        if (needDisplay) {
            screenView.setNeedsDisplay()
            needDisplay = true
        }
        if let cpu = self.cpu {
            cpu.updateTimers()
        }
    }

    
    @IBAction func onDebugCheckBoxChange(sender: NSButton) {
        let drawDebugInfo = sender.state == NSOnState
        screenView.setDrawDebugInfo(drawDebugInfo)
    }
    
    @IBAction func onSoundCheckBoxChangeState(sender: NSButton) {
        isPlaySound = sender.state == NSOnState
    }
}

