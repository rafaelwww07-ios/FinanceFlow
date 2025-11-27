# FinanceFlow Extensions Setup Guide

Этот документ описывает настройку расширений для FinanceFlow.

## 1. Widget Extension

### Настройка в Xcode:

1. **Создание Widget Extension:**
   - File → New → Target
   - Выберите "Widget Extension"
   - Название: `FinanceFlowWidget`
   - Bundle Identifier: `com.financeflow.app.FinanceFlowWidget`
   - Включите "Include Configuration Intent" (опционально)

2. **App Group:**
   - Выберите основной таргет приложения
   - Signing & Capabilities → + Capability → App Groups
   - Добавьте: `group.com.financeflow.app`
   - Повторите для Widget Extension

3. **Core Data Sharing:**
   - Убедитесь, что оба таргета используют один и тот же `.xcdatamodeld` файл
   - Добавьте `FinanceFlowModel.xcdatamodeld` в Widget Extension

4. **Файлы для Widget Extension:**
   - `FinanceFlowWidget.swift` - основной виджет
   - `SharedData.swift` - общий доступ к Core Data
   - `Info.plist` - конфигурация расширения

## 2. App Intents Extension (Siri Shortcuts)

### Настройка в Xcode:

1. **Создание App Intents Extension:**
   - File → New → Target
   - Выберите "App Intents Extension"
   - Название: `FinanceFlowIntents`
   - Bundle Identifier: `com.financeflow.app.FinanceFlowIntents`

2. **Файлы для Intents Extension:**
   - `FinanceFlowIntents.swift` - определения интентов
   - `Info.plist` - конфигурация расширения

3. **Доступные Siri Shortcuts:**
   - "Add transaction in FinanceFlow"
   - "Show balance in FinanceFlow"
   - "Add expense [amount] in FinanceFlow"

## 3. CloudKit Setup

### Настройка в Apple Developer Console:

1. **Создание CloudKit Container:**
   - Перейдите в Apple Developer Console
   - Certificates, Identifiers & Profiles
   - Identifiers → App IDs
   - Выберите ваш App ID
   - Включите CloudKit capability
   - Создайте CloudKit Container с ID: `iCloud.com.financeflow.app`

2. **В Xcode:**
   - Выберите основной таргет
   - Signing & Capabilities → + Capability → CloudKit
   - Выберите созданный Container

3. **Схема данных:**
   - Откройте CloudKit Dashboard
   - Создайте Record Types:
     - Transaction
     - Category
     - Budget
     - Goal
     - Account

## 4. Info.plist Permissions

Все необходимые разрешения уже добавлены в `Info.plist`:

- **NSMicrophoneUsageDescription** - для голосового ввода
- **NSSpeechRecognitionUsageDescription** - для распознавания речи
- **NSPhotoLibraryUsageDescription** - для фото чеков
- **NSCameraUsageDescription** - для камеры
- **NSUserTrackingUsageDescription** - для аналитики (опционально)

## 5. App Group Configuration

### Для работы виджетов:

1. **Создание App Group:**
   - Apple Developer Console → Identifiers → App Groups
   - Создайте: `group.com.financeflow.app`

2. **В Xcode:**
   - Добавьте App Groups capability к обоим таргетам
   - Используйте один и тот же Group ID

3. **UserDefaults Sharing:**
   - Используйте `UserDefaults(suiteName: "group.com.financeflow.app")`
   - Для синхронизации настроек между приложением и виджетом

## 6. Build Settings

### Общие настройки:

1. **Deployment Target:**
   - iOS 16.0+ для основного приложения
   - iOS 16.0+ для Widget Extension
   - iOS 16.0+ для App Intents Extension

2. **Swift Version:**
   - Swift 5.9+

3. **Framework Linking:**
   - WidgetKit
   - AppIntents
   - CloudKit
   - CoreData
   - Speech
   - AVFoundation

## 7. Testing

### Тестирование виджетов:

1. Запустите приложение на симуляторе/устройстве
2. Добавьте виджет на главный экран
3. Проверьте обновление данных

### Тестирование Siri Shortcuts:

1. Откройте Settings → Siri & Search
2. Найдите FinanceFlow
3. Добавьте shortcuts
4. Протестируйте голосовые команды

### Тестирование CloudKit:

1. Войдите в iCloud на устройстве
2. Включите синхронизацию в настройках приложения
3. Проверьте синхронизацию между устройствами

## 8. Troubleshooting

### Виджет не обновляется:
- Проверьте App Group configuration
- Убедитесь, что Core Data использует App Group container
- Проверьте timeline policy в Provider

### Siri Shortcuts не работают:
- Убедитесь, что App Intents Extension добавлен в проект
- Проверьте Bundle Identifier
- Перезапустите устройство

### CloudKit ошибки:
- Проверьте Container ID
- Убедитесь, что CloudKit включен в capabilities
- Проверьте схему данных в CloudKit Dashboard

## 9. Production Checklist

- [ ] App Group создан и настроен
- [ ] CloudKit Container создан
- [ ] Все разрешения добавлены в Info.plist
- [ ] Widget Extension протестирован
- [ ] Siri Shortcuts протестированы
- [ ] CloudKit синхронизация работает
- [ ] Все Bundle Identifiers уникальны
- [ ] Signing & Capabilities настроены для всех таргетов


