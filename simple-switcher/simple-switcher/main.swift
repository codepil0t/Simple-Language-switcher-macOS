import Cocoa
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: fourCharCodeFrom("SSWT"), id: 1)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем иконку в статус баре
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: "Switch Language")
        }
        
        setupMenus()
        registerHotKey()
        
        // Выводим информацию о доступных источниках ввода в консоль для отладки
        printAvailableInputSources()
    }
    
    func setupMenus() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Выход", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func registerHotKey() {
        print("Регистрация горячей клавиши CMD+Space")
        
        // Устанавливаем обработчик события для горячей клавиши
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        // Создаем обработчик событий
        let result = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                let selfPointer = userData
                let mySelf = Unmanaged<AppDelegate>.fromOpaque(selfPointer!).takeUnretainedValue()
                
                var hkID = EventHotKeyID()
                
                GetEventParameter(
                    theEvent,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hkID
                )
                
                if hkID.signature == mySelf.hotKeyID.signature && hkID.id == mySelf.hotKeyID.id {
                    print("Горячая клавиша CMD+Space нажата")
                    mySelf.switchInputLanguage()
                    return noErr
                }
                
                return CallNextEventHandler(nextHandler, theEvent)
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
        
        if result != noErr {
            print("Ошибка при регистрации обработчика событий: \(result)")
            return
        }
        
        // Регистрируем горячую клавишу CMD+Space
        let modifiers = UInt32(cmdKey)
        let keyCode: UInt32 = 49 // Space
        
        let registerResult = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerResult != noErr {
            print("Ошибка при регистрации горячей клавиши: \(registerResult)")
        } else {
            print("Горячая клавиша CMD+Space успешно зарегистрирована")
        }
    }
    
    func printAvailableInputSources() {
        // Получаем список доступных источников ввода
        let properties = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource]
        let inputSourceList = TISCreateInputSourceList(properties as CFDictionary, false).takeRetainedValue() as! [TISInputSource]
        
        print("Доступные источники ввода:")
        for (index, source) in inputSourceList.enumerated() {
            if let sourceID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceID).takeUnretainedValue() as String
                print("[\(index)] ID: \(sourceIDString)")
            }
        }
    }
    
    func switchInputLanguage() {
        print("Переключение языка")
        
        // Получаем текущий источник ввода
        let inputSource = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
        
        // Получаем список доступных источников ввода
        let properties = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource]
        let inputSourceList = TISCreateInputSourceList(properties as CFDictionary, false).takeRetainedValue() as! [TISInputSource]
        
        // Отфильтруем активные источники ввода клавиатуры
        let keyboardInputSources = inputSourceList.filter { source in
            if let category = TISGetInputSourceProperty(source, kTISPropertyInputSourceCategory) {
                return Unmanaged<CFString>.fromOpaque(category).takeUnretainedValue() as String == kTISCategoryKeyboardInputSource as String
            }
            return false
        }
        
        if keyboardInputSources.count > 1 {
            // Находим текущий источник ввода в списке
            var currentIndex = -1
            
            if let currentID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) {
                let currentIDString = Unmanaged<CFString>.fromOpaque(currentID).takeUnretainedValue() as String
                print("Текущий источник ввода: \(currentIDString)")
                
                for (index, source) in keyboardInputSources.enumerated() {
                    if let sourceID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) {
                        let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceID).takeUnretainedValue() as String
                        
                        if sourceIDString == currentIDString {
                            currentIndex = index
                            break
                        }
                    }
                }
            }
            
            // Если текущий источник найден, переключаем на следующий
            if currentIndex >= 0 {
                let nextIndex = (currentIndex + 1) % keyboardInputSources.count
                let nextSource = keyboardInputSources[nextIndex]
                
                if let sourceID = TISGetInputSourceProperty(nextSource, kTISPropertyInputSourceID) {
                    let sourceIDString = Unmanaged<CFString>.fromOpaque(sourceID).takeUnretainedValue() as String
                    print("Переключение на: \(sourceIDString)")
                }
                
                let selectResult = TISSelectInputSource(nextSource)
                if selectResult != noErr {
                    print("Ошибка при переключении источника ввода: \(selectResult)")
                } else {
                    print("Источник ввода успешно переключен")
                }
            }
        } else {
            print("Доступен только один источник ввода")
        }
    }
    
    deinit {
        // Удаляем горячую клавишу и обработчик событий
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}

// Вспомогательная функция для создания OSType из 4-символьного кода
func fourCharCodeFrom(_ string: String) -> FourCharCode {
    guard string.count == 4 else { return 0 }
    var result: FourCharCode = 0
    for (index, character) in string.utf16.enumerated() {
        result |= FourCharCode(character) << (8 * (3 - index))
    }
    return result
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Скрываем иконку из Dock
NSApp.setActivationPolicy(.accessory)

app.run() 