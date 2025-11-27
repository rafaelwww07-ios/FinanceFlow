# FinanceFlow - Инструкции по настройке расширений

## 📋 Обзор

Этот проект включает Widget Extension и App Intents Extension. Следуйте этим инструкциям для полной настройки.

## 🔧 Шаг 1: Добавление таргетов в Xcode

### Widget Extension

1. Откройте проект в Xcode
2. File → New → Target
3. Выберите **Widget Extension**
4. Название: `FinanceFlowWidget`
5. Bundle Identifier: `com.rafael.mukhametov.FinanceFlow.FinanceFlowWidget`
6. ✅ Включите "Include Configuration Intent" (опционально)
7. Нажмите Finish

### App Intents Extension

1. File → New → Target
2. Выберите **App Intents Extension**
3. Название: `FinanceFlowIntents`
4. Bundle Identifier: `com.rafael.mukhametov.FinanceFlow.FinanceFlowIntents`
5. Нажмите Finish

## 📁 Шаг 2: Добавление файлов в таргеты

### Для Widget Extension:

1. Перетащите `FinanceFlowWidget/FinanceFlowWidget.swift` в проект
2. Перетащите `FinanceFlowWidget/SharedData.swift` в проект
3. Перетащите `FinanceFlowWidget/Info.plist` в проект
4. Убедитесь, что файлы добавлены в таргет `FinanceFlowWidget`
5. Добавьте `FinanceFlowModel.xcdatamodeld` в таргет `FinanceFlowWidget`

### Для App Intents Extension:

1. Перетащите `FinanceFlowIntents/FinanceFlowIntents.swift` в проект
2. Перетащите `FinanceFlowIntents/Info.plist` в проект
3. Убедитесь, что файлы добавлены в таргет `FinanceFlowIntents`

## 🔐 Шаг 3: Настройка App Group

### В Apple Developer Console:

1. Перейдите на [developer.apple.com](https://developer.apple.com)
2. Certificates, Identifiers & Profiles → Identifiers
3. Нажмите "+" для создания нового App Group
4. Description: `FinanceFlow App Group`
5. Identifier: `group.com.financeflow.app`
6. Нажмите Continue и Register

### В Xcode:

1. Выберите таргет **FinanceFlow** (основное приложение)
2. Signing & Capabilities → + Capability
3. Выберите **App Groups**
4. Добавьте: `group.com.financeflow.app`
5. Повторите для таргетов:
   - `FinanceFlowWidget`
   - `FinanceFlowIntents`

## ☁️ Шаг 4: Настройка CloudKit

### В Apple Developer Console:

1. Certificates, Identifiers & Profiles → Identifiers
2. Выберите ваш App ID (`com.rafael.mukhametov.FinanceFlow`)
3. Включите **CloudKit** capability
4. Сохраните изменения

### В Xcode:

1. Выберите таргет **FinanceFlow**
2. Signing & Capabilities → + Capability
3. Выберите **CloudKit**
4. Container: Создайте новый или используйте существующий
5. Container Identifier: `iCloud.com.financeflow.app`

### CloudKit Dashboard:

1. Перейдите на [icloud.developer.apple.com](https://icloud.developer.apple.com)
2. Выберите ваш Container
3. Создайте Record Types:
   - **Transaction** (с полями: amount, date, note, type, category)
   - **Category** (с полями: name, icon, colorHex, transactionType)
   - **Budget** (с полями: amount, period, category)
   - **Goal** (с полями: name, targetAmount, currentAmount)
   - **Account** (с полями: name, balance, colorHex, icon)

## 📱 Шаг 5: Настройка Info.plist

Файл `FinanceFlow/Info.plist` уже создан с необходимыми разрешениями:

- ✅ NSMicrophoneUsageDescription
- ✅ NSSpeechRecognitionUsageDescription
- ✅ NSPhotoLibraryUsageDescription
- ✅ NSCameraUsageDescription

Убедитесь, что он добавлен в проект и используется таргетом.

## 🔗 Шаг 6: Общие файлы и зависимости

### Добавьте в Widget Extension:

- `FinanceFlow/Helpers/CurrencyFormatter.swift`
- `FinanceFlow/Models/TransactionType.swift`
- `FinanceFlow/CoreData/FinanceFlowModel.xcdatamodeld`

### Добавьте в App Intents Extension:

- `FinanceFlow/Models/TransactionType.swift` (если нужен)

## ⚙️ Шаг 7: Build Settings

### Для всех таргетов:

1. **Deployment Target**: iOS 16.0+
2. **Swift Version**: 5.9+
3. **Framework Linking**:
   - WidgetKit (для Widget Extension)
   - AppIntents (для App Intents Extension)
   - CloudKit (для основного приложения)
   - CoreData (для всех)

## 🧪 Шаг 8: Тестирование

### Виджет:

1. Запустите приложение на устройстве/симуляторе
2. Долго нажмите на главный экран
3. Нажмите "+" в левом верхнем углу
4. Найдите "FinanceFlow Widget"
5. Добавьте виджет
6. Проверьте обновление данных

### Siri Shortcuts:

1. Settings → Siri & Search
2. Найдите "FinanceFlow"
3. Добавьте shortcuts
4. Протестируйте команды:
   - "Add transaction in FinanceFlow"
   - "Show balance in FinanceFlow"
   - "Add expense 50 in FinanceFlow"

### CloudKit:

1. Войдите в iCloud на устройстве
2. Откройте приложение
3. Settings → iCloud Sync → Enable
4. Проверьте синхронизацию между устройствами

## 🐛 Troubleshooting

### Виджет не показывает данные:

- Проверьте App Group configuration
- Убедитесь, что Core Data использует App Group container
- Проверьте, что `SharedData.swift` правильно настроен

### Siri Shortcuts не работают:

- Убедитесь, что App Intents Extension добавлен
- Проверьте Bundle Identifier
- Перезапустите устройство

### CloudKit ошибки:

- Проверьте Container ID
- Убедитесь, что CloudKit включен в capabilities
- Проверьте схему данных в CloudKit Dashboard
- Убедитесь, что вы вошли в iCloud

### Ошибки компиляции:

- Убедитесь, что все файлы добавлены в правильные таргеты
- Проверьте, что все зависимости подключены
- Очистите Build Folder (Cmd+Shift+K) и пересоберите

## ✅ Checklist перед релизом

- [ ] Все таргеты созданы и настроены
- [ ] App Group создан и добавлен ко всем таргетам
- [ ] CloudKit Container создан и настроен
- [ ] Info.plist содержит все разрешения
- [ ] Виджет протестирован
- [ ] Siri Shortcuts протестированы
- [ ] CloudKit синхронизация работает
- [ ] Все Bundle Identifiers уникальны
- [ ] Signing & Capabilities настроены для всех таргетов

## 📚 Дополнительные ресурсы

- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Intents Documentation](https://developer.apple.com/documentation/appintents)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [App Groups Documentation](https://developer.apple.com/documentation/xcode/configuring-app-groups)


