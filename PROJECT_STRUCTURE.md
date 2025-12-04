# 📁 Estrutura do Projeto Miio

## Organização de Arquivos

```
Miio/
├── README.md                    # Documentação principal
├── LICENSE                      # Licença do projeto
├── Miio.xcodeproj/              # Projeto Xcode
└── Miio/
    ├── MiioApp.swift            # Ponto de entrada do app
        │
        ├── Models/              # Modelos de Dados
        │   ├── Entry.swift      # Modelo de entrada do diário
        │   └── EntryStore.swift # Gerenciador de persistência
        │
        ├── ViewModels/          # ViewModels (MVVM)
        │   └── EntryViewModel.swift
        │
        ├── Views/               # Views SwiftUI
        │   ├── EntryListView.swift    # Lista de entradas
        │   ├── EntryDetailView.swift  # Detalhes da entrada
        │   └── EntryEditView.swift    # Criar/Editar entrada
        │
        ├── Services/            # Serviços
        │   ├── FoundationModelsService.swift  # IA e análise de texto
        │   └── ShareService.swift             # Compartilhamento
        │
        ├── AppIntents/          # Integração Siri/Shortcuts
        │   ├── CreateEntryIntent.swift
        │   └── MiioAppShortcuts.swift
        │
        ├── DesignSystem/        # Sistema de Design
        │   └── DesignSystem.swift
        │
        ├── Extensions/          # Extensões Swift
        │   ├── Animation+Extensions.swift
        │   ├── Date+Extensions.swift
        │   ├── String+Extensions.swift
        │   └── ViewBuilder+Extensions.swift
        │
        ├── Utilities/           # Utilitários
        │   └── AppConfiguration.swift
        │
        └── Assets.xcassets/    # Recursos visuais
            ├── AppIcon.appiconset/
            └── AccentColor.colorset/
```

## Convenções de Nomenclatura

- **Models**: Substantivos no singular (`Entry`, `Location`, `Photo`)
- **ViewModels**: Sufixo `ViewModel` (`EntryViewModel`)
- **Views**: Sufixo `View` (`EntryListView`, `EntryDetailView`)
- **Services**: Sufixo `Service` (`ShareService`, `FoundationModelsService`)
- **Extensions**: Formato `Type+Extensions.swift` (`Date+Extensions.swift`)

## Padrões de Código

### Documentação
Todos os arquivos, tipos, funções e propriedades públicas são documentados usando `///`:

```swift
/// Descrição do que faz
/// - Parameter name: Descrição do parâmetro
/// - Returns: Descrição do retorno
func example(name: String) -> String
```

### MARK Comments
Uso de `// MARK:` para organização:

```swift
// MARK: - Properties
// MARK: - Methods
// MARK: - Private Methods
// MARK: - Previews
```

### Previews
Todas as views possuem previews nomeados:

```swift
#Preview("Nome Descritivo") {
    // Código do preview
}
```

## Dependências

- **SwiftUI**: Framework de UI
- **Combine**: Programação reativa
- **CoreLocation**: Localização GPS
- **PhotosUI**: Seleção de fotos
- **AppIntents**: Integração com Siri
- **Foundation**: Framework base

## Requisitos do Sistema

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

