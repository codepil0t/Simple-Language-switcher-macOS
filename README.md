# Simple Switcher

Простое приложение для macOS, которое позволяет переключать языки ввода с помощью комбинации клавиш CMD + Space. Приложение отображается только в строке состояния macOS и не показывается в Dock.

## Возможности
- Переключение языка ввода с помощью CMD + Space
- Запуск только в строке состояния (статус баре)
- Минималистичный пользовательский интерфейс

## Требования
- macOS 10.13 или новее
- Xcode 13.0 или новее (для компиляции)

## Компиляция

### Через Xcode
1. Откройте файл проекта `simple-switcher.xcodeproj` в Xcode
2. Выберите меню Product -> Build (⌘+B)
3. После успешной компиляции приложение будет доступно в папке `build`

### Через командную строку
```bash
cd simple-switcher
xcodebuild -project simple-switcher.xcodeproj -configuration Release
```

## Установка
1. Скопируйте скомпилированное приложение (расположение смотри в логах команды xcodebuild) `simple-switcher.app` в папку `/Applications`
2. Запустите приложение двойным щелчком

## Настройка разрешений

При первом запуске приложения вам потребуется предоставить разрешения:

1. **Разрешение на мониторинг ввода с клавиатуры**
   - macOS покажет запрос на доступ к мониторингу ввода
   - Для предоставления разрешения вручную:
     - Откройте Системные настройки -> Безопасность и конфиденциальность -> Конфиденциальность -> Мониторинг ввода
     - Установите флажок напротив "simple-switcher"

2. **Автозапуск (опционально)**
   - Чтобы добавить приложение в автозагрузку:
     - Откройте Системные настройки -> Учетные записи пользователей -> Элементы входа
     - Нажмите "+" и выберите приложение "simple-switcher"

## Использование
- После запуска приложения вы увидите иконку глобуса в строке состояния macOS
- Нажмите CMD + Space для переключения между языками ввода
- Для выхода из приложения щелкните правой кнопкой мыши по иконке в строке состояния и выберите "Выход"

## Примечания
- Эта программа конфликтует со стандартной функцией Spotlight в macOS, которая тоже использует комбинацию CMD + Space. Рекомендуется изменить комбинацию клавиш для Spotlight в системных настройках. 